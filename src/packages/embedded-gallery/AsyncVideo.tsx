import { FunctionComponent } from 'preact';

interface AsyncVideoProps {
  poster: string;
  src: string;
}

const AsyncVideo: FunctionComponent<AsyncVideoProps> = ({ poster, src }) => {

  return (
    <video autoplay muted loop playsinline poster={poster}>
      <source src={src} type="video/mp4" />
    </video>
  );
};

export default AsyncVideo;