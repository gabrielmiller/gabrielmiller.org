1. Prepare images in advance.
  - All mp4 files should have identical filename (except extension) as their sibling jpg file.
  - All extensions should be lower case.
  - Thumbnails should exist for all jpgs.
  - Thumbnails should have a 1:1 aspect ratio.
  - Put images into directories specified by respective scripts.
2. Empty the dir where processed assets will go.
2. Process the full size images with `process_raw_images.sh`
3. Process the thumbnails with `process_thumbs.sh`
4. Upload the files to size with `upload_to_s3.sh`