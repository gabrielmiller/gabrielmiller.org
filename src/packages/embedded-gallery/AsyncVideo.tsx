import { FunctionComponent } from 'preact';
import { useEffect, useRef, useState } from 'preact/hooks';

interface AsyncVideoProps {
  poster: string;
  src: string;
}

const AsyncVideo: FunctionComponent<AsyncVideoProps> = (props) => {
  const [isLoaded, setIsLoaded] = useState(false);
  const [showElement, setShowElement] = useState(false);

  const onCanPlaythrough = (event: any) => {
    setIsLoaded(true);
  }

  useEffect(() => {
    // Deliberately unmount and then remount the video element when the src
    // changes in order to properly reset the video player.
    setShowElement(false);
    setIsLoaded(false);
  }, [props.src]);

  useEffect(() => {
    if (showElement) {
      return;
    }
    setShowElement(true);
  }, [showElement])

  return (
    <>
      {isLoaded === false && (
        <span class="loader"></span>
      )}
      {showElement && (
        <video onCanPlayThrough={(event) => onCanPlaythrough(event)} autoplay muted loop playsinline poster={props.poster}>
          <source src={props.src} type="video/mp4" />
        </video>
      )}
    </>
  );
};

export default AsyncVideo;