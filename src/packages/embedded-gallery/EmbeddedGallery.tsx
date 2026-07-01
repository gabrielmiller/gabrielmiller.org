import { FunctionComponent } from 'preact';
import { useEffect, useState } from 'preact/hooks';
import IconArrowLeftCircle from './IconArrowLeftCircle';
import IconArrowRightCircle from './IconArrowRightCircle';
import IconXMarkCircle from './IconXMarkCircle';
import AsyncImage from './AsyncImage';

interface IEmbeddedGalleryProps {
  currentEntry: string,
  entries: IEntry[],
  incrementer: Date
}

interface IEntry {
  original: string,
  thumb: string,
  video?: string,
  web: string
}

interface IEntryMap {
  [key: string]: number
}

const EmbeddedGallery: FunctionComponent<IEmbeddedGalleryProps> = ({ currentEntry, entries, incrementer }) => {
  const [currentEntryIndex, setCurrentEntryIndex] = useState(0);
  const [isVisible, setIsVisible] = useState(false);
  const [thumbToIndexMap, setThumbToIndexMap] = useState<IEntryMap>({});
  const isActive = () => {
    return currentEntry !== undefined;
  }

  const navigateToNextEntry = () => {
    setCurrentEntryIndex(currentEntryIndex + 1);
  };

  const navigateToPrevEntry = () => {
    setCurrentEntryIndex(currentEntryIndex - 1);
  };

  const validateCanNavigateToNextEntry = (): boolean => {
    return currentEntryIndex !== (entries.length - 1);
  };

  const validateCanNavigateToPrevEntry = (): boolean => {
    return currentEntryIndex != 0;
  };

  useEffect(() => {
    const entryMap: IEntryMap = {};
    for (let i = 0; i < entries.length; i++) {
      entryMap[entries[i].thumb] = i;
    }

    setThumbToIndexMap(entryMap);
  }, []);

  useEffect(() => {
    if (isActive()) {
      setCurrentEntryIndex(thumbToIndexMap[currentEntry]);
    }

    const keyboardListener = (event) => {
      if (event.code === "Escape") {
        setIsVisible(false);
      } else if (event.code === "ArrowLeft" && validateCanNavigateToPrevEntry()) {
        navigateToPrevEntry();
      } else if (event.code === "ArrowRight" && validateCanNavigateToNextEntry()) {
        navigateToNextEntry();
      }
    };

    document.addEventListener("keydown", keyboardListener);

    return () => {
      document.removeEventListener("keydown", keyboardListener);
    };

  }, [currentEntry]);

  useEffect(() => {
    if (!isActive()) {
      return
    }
    setIsVisible(true);
  }, [incrementer])

  return (
    <div class={isVisible ? "visible" : "hidden"} id="embedded-gallery-overlay">
      {isActive() &&
        <div>
          <div class={`album-container`}>
            <AsyncImage src={entries[currentEntryIndex].web} />
          </div>
          <button
            class="control-close-viewer"
            onClick={() => setIsVisible(false)}
            title="Close viewer"
            type="button">
            <IconXMarkCircle />
          </button>
          <button
            class="control-navigate-previous"
            disabled={!validateCanNavigateToPrevEntry()}
            onClick={() => navigateToPrevEntry()}
            title="Navigate to previous entry"
            type="button">
            <IconArrowLeftCircle />
          </button>
          <button
            class="control-navigate-next"
            disabled={!validateCanNavigateToNextEntry()}
            onClick={() => navigateToNextEntry()}
            title="Navigate to next entry"
            type="button">
            <IconArrowRightCircle />
          </button>
        </div>
      }
    </div>
  );
};

export default EmbeddedGallery;