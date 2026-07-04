import { FunctionComponent } from 'preact';
import { useEffect, useState } from 'preact/hooks';

interface AsyncVideoProps {
  poster: string;
  src: string;
}

const AsyncVideo: FunctionComponent<AsyncVideoProps> = ({ poster, src }) => {
  const [showVideo, setShowVideo] = useState(true);

  useEffect(() => {
    // This deliberately makes the video element exit and re-enter the dom
    // when the src changes. This seems to be necessary for the content to
    // properly change when navigating through media.
    setShowVideo(false);
    setTimeout(() => {
      setShowVideo(true);
    })
  }, [src]);

  return (
    <>
      {showVideo && (
        <video autoplay muted loop playsinline poster={poster}>
          <source src={src} type="video/mp4" />
        </video>
      )}
    </>
  );
};

export default AsyncVideo;