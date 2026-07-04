import { FunctionComponent } from 'preact';
import { useEffect, useRef, useState } from 'preact/hooks';

interface AsyncVideoProps {
  poster: string;
  src: string;
}

const AsyncVideo: FunctionComponent<AsyncVideoProps> = (props) => {
  const [loadedSrc, setLoadedSrc] = useState(null);
  const [showVideo, setShowVideo] = useState(true);
  const ref = useRef(null);

  useEffect(() => {
    // This deliberately makes the video element exit and re-enter the dom
    // when the src changes. This seems to be necessary for the content to
    // properly change when navigating through media.
    setShowVideo(false);
    setTimeout(() => {
      setShowVideo(true);
    })

    setLoadedSrc(null);
    if (props.src) {
      const handleCanPlaythrough = () => {
        setLoadedSrc(props.src);
      };
      const video = document.createElement('video');
      video.addEventListener('canplaythrough', handleCanPlaythrough);
      video.src = props.src;
      return () => {
        video.removeEventListener('canplaythrough', handleCanPlaythrough);
      };
    }

  }, [props.src]);

  return (
    <>
      {loadedSrc !== props.src && (
        <span class="loader"></span>
      )}

      {showVideo && (
        <video ref={ref} autoplay muted loop playsinline poster={props.poster}>
          {loadedSrc === props.src && (
            <source src={loadedSrc} type="video/mp4" />
          )}
        </video>
      )}
    </>
  );
};

export default AsyncVideo;