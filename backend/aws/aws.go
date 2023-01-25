package aws

import (
    "context"
    "encoding/json"
    "io"
    "log"
    "os"
    "regexp"
    "github.com/aws/aws-sdk-go-v2/aws"
    "github.com/aws/aws-sdk-go-v2/aws/signer/v4"
    "github.com/aws/aws-sdk-go-v2/config"
    "github.com/aws/aws-sdk-go-v2/service/s3"
    "github.com/aws/aws-sdk-go-v2/service/s3/types"
    "time"
)

type StoryIndex struct {
    AccessToken string
    Entries []StoryEntry `json:"entries"`
    Metadata map[string]interface{} `json:"metadata"`
}

type StoryEntry struct {
    Filename string `json:"filename"`
    Metadata map[string]interface{} `json:"metadata"`
}

type Presigner struct {
	PresignClient *s3.PresignClient
}

func (presigner Presigner) getObject(objectKey string, lifetimeSecs int64) (*v4.PresignedHTTPRequest, error) {
	request, err := presigner.PresignClient.PresignGetObject(context.TODO(), &s3.GetObjectInput{
		Bucket: aws.String(os.Getenv("S3_BUCKET_NAME")),
		Key:    aws.String(objectKey),
	}, func(opts *s3.PresignOptions) {
		opts.Expires = time.Duration(lifetimeSecs * int64(time.Second))
	})
	if err != nil {
        return nil, err
	}
	return request, nil
}

type BucketBasics struct {
	S3Client *s3.Client
}

func (basics BucketBasics) listObjects() ([]types.Object, error) {
	result, err := basics.S3Client.ListObjectsV2(context.TODO(), &s3.ListObjectsV2Input{
		Bucket: aws.String(os.Getenv("S3_BUCKET_NAME")),
	})
	var contents []types.Object
	if err != nil {
		log.Printf("Couldn't list objects in bucket %v. Here's why: %v\n", os.Getenv("S3_BUCKET_NAME"), err)
	} else {
		contents = result.Contents
	}
	return contents, err
}

func (basics BucketBasics) getS3FileInMemory(objectKey string) (string, error) {
	result, err := basics.S3Client.GetObject(context.TODO(), &s3.GetObjectInput{
		Bucket: aws.String(os.Getenv("S3_BUCKET_NAME")),
		Key:    aws.String(objectKey),
	})
	if err != nil {
        return "", err
	}

    var reader io.Reader
    reader = result.Body
    data, _ := io.ReadAll(reader)
    return string(data), nil
}

func GetIndexForStory(story string) (string, error) {
    bucket := getConnection()
    return bucket.getS3FileInMemory(story + "/index.json")
}

func GetEntriesForStoryByPage(story string, accessToken string, page int, perPage int) ([]string, error) {
    indexFile, err := GetIndexForStory(story)
    if err != nil {
        return nil, err
    }

    var Index StoryIndex
    json.Unmarshal([]byte(indexFile), &Index)
    if (Index.AccessToken != accessToken) {
        return nil, err
    }

    maxEntries := len(Index.Entries)
    pageStartIndex := (page - 1)
    pageEndIndex := pageStartIndex + perPage

    if (pageEndIndex > maxEntries) {
        pageEndIndex = maxEntries
    }
    paginatedEntries := Index.Entries[pageStartIndex:pageEndIndex]

    var urls []string
    for _, element := range paginatedEntries {
        url, err := GetPresignUrl(story, element.Filename)

        if err != nil {
            return nil, err
        }

        urls = append(urls, url)
    }

    return urls, nil
}

func GetPresignUrl(story string, key string) (string, error) {
    bucket := getConnection()
    presignClient := s3.NewPresignClient(bucket.S3Client)
    presigner := Presigner{ PresignClient: presignClient }
    file, err := presigner.getObject(story + "/" + key, 90)

    if err != nil {
        return "", err
    }

    return file.URL, nil
}

func ListBucketContents() ([]string) {

    bucket := getConnection()
    contents, err := bucket.listObjects()
    if err != nil {
        panic(err)
    }

    filesInBucket := []string{}

    // These are some arbitrary rules I'm going to follow when uploading files
    // but if actual user input were accepted here you might want to give this
    // regular expression deeper scrutiny.
    //
    // Its intent is to filter out s3 objects that do not look like images.
    // I intend for keys to be one "directory" deep and therefore have not 
    // tested with more than one "directory" in my keys than that.
    //
    // Legend:
    // 0 = "final directory closing" slash
    // 1 = capture group for n digits followed by a period
    // 2 = capture group / OR clause for extensions of interest
    // 3 = must match end of string
    //
    //          0001111111122222222213
    pattern := "\\/(\\d*\\.(jpg|gif))$"
    r, _ := regexp.Compile(pattern)
    for _, file := range contents {
        name := *file.Key
        m := r.FindStringSubmatch(name)      
        if (len(m) > 0) {
            filesInBucket = append(filesInBucket, name)
        }
    }

    return filesInBucket
}

func getConnection() (BucketBasics) {
    cfg, err := config.LoadDefaultConfig(context.TODO())
    if err != nil {
        panic(err)
    }

    S3Client := s3.NewFromConfig(cfg)

    return BucketBasics{S3Client: S3Client}
}