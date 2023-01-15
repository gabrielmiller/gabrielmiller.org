package aws

import (
    "context"
    "log"
    "os"
    "regexp"
	"github.com/aws/aws-sdk-go-v2/aws"
    "github.com/aws/aws-sdk-go-v2/config"
    "github.com/aws/aws-sdk-go-v2/service/s3"
    "github.com/aws/aws-sdk-go-v2/service/s3/types"
)

type BucketBasics struct {
	S3Client *s3.Client
}

func (basics BucketBasics) ListObjects(bucketName string) ([]types.Object, error) {
	result, err := basics.S3Client.ListObjectsV2(context.TODO(), &s3.ListObjectsV2Input{
		Bucket: aws.String(bucketName),
	})
	var contents []types.Object
	if err != nil {
		log.Printf("Couldn't list objects in bucket %v. Here's why: %v\n", bucketName, err)
	} else {
		contents = result.Contents
	}
	return contents, err
}

func GetIndexForStory(story string) ([]string) {

    cfg, err := config.LoadDefaultConfig(context.TODO())
    S3Client := s3.NewFromConfig(cfg)

    bucket := BucketBasics{S3Client: S3Client}
    contents, err := bucket.ListObjects(os.Getenv("S3_BUCKET_NAME"))
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