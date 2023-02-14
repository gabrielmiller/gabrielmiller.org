package aws

import (
    "context"
    "encoding/json"
    "errors"
    "io"
    "os"
    "github.com/aws/aws-sdk-go-v2/aws"
    "github.com/aws/aws-sdk-go-v2/aws/signer/v4"
    "github.com/aws/aws-sdk-go-v2/config"
    "github.com/aws/aws-sdk-go-v2/service/s3"
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

func GetIndexForStory(story string, accessToken string) (StoryIndex, error) {
    var Index StoryIndex

    bucket, err := getConnection()
    if err != nil {
        return Index, err
    }

    indexFile, err := bucket.getS3FileInMemory(story + "/index.json")
    if err != nil {
        return Index, err
    }

    json.Unmarshal([]byte(indexFile), &Index)
    if (Index.AccessToken != accessToken) {
        err = errors.New("Invalid token for story")
        return Index, err
    }

    Index.AccessToken = "";

    return Index, nil
}

func GetEntriesForStory(story string, accessToken string, page int, perPage int) ([]string, error) {
    Index, err := GetIndexForStory(story, accessToken)
    if err != nil {
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
    bucket, err := getConnection()
    if err != nil {
        return "", err
    }

    presignClient := s3.NewPresignClient(bucket.S3Client)
    presigner := Presigner{ PresignClient: presignClient }
    file, err := presigner.getObject(story + "/" + key, 90)

    if err != nil {
        return "", err
    }

    return file.URL, nil
}

func getConnection() (BucketBasics, error) {
    cfg, err := config.LoadDefaultConfig(context.TODO())
    if err != nil {
        return BucketBasics{}, err
    }

    S3Client := s3.NewFromConfig(cfg)

    return BucketBasics{S3Client: S3Client}, nil
}