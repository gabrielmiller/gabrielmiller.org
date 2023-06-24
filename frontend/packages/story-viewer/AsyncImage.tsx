import { FunctionComponent } from 'preact';
import { useEffect, useState } from 'preact/hooks';

interface AsyncImageProps {
    src: string;
}

const AsyncImage: FunctionComponent<AsyncImageProps> = (props) => {
    const [loadedSrc, setLoadedSrc] = useState(null);

    useEffect(() => {
        setLoadedSrc(null);
        if (props.src) {
            const handleLoad = () => {
                setLoadedSrc(props.src);
            };
            const image = new Image();
            image.addEventListener('load', handleLoad);
            image.src = props.src;
            return () => {
                image.removeEventListener('load', handleLoad);
            };
        }
    }, [props.src]);

    if (loadedSrc === props.src) {
        return (
            <img {...props} />
        );
    }

    return <span class="loader"></span>;
};

export default AsyncImage;