import { FunctionComponent } from 'preact';
import { useEffect, useState } from 'preact/hooks';
import IconArrowLeftCircle from './IconArrowLeftCircle';
import IconArrowRightCircle from './IconArrowRightCircle';
import AsyncImage from './AsyncImage';

interface IEmbeddedGalleryProps {
  currentEntry: string,
  entries: IEntry[]
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

const EmbeddedGallery: FunctionComponent<IEmbeddedGalleryProps> = ({ currentEntry, entries }) => {
  console.log("EmbeddedGallery rendered!")
  console.log({ entries })
  const [currentEntryIndex, setCurrentEntryIndex] = useState(0);
  const [thumbToIndexMap, setThumbToIndexMap] = useState<IEntryMap>({});

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

    setThumbToIndexMap(entryMap)
  }, []);

  useEffect(() => {
    const index = thumbToIndexMap[currentEntry];
    setCurrentEntryIndex(index);

    const kbListener = (event) => {
      if (event.code === "ArrowLeft" && validateCanNavigateToPrevEntry()) {
        navigateToPrevEntry();
      } else if (event.code === "ArrowRight" && validateCanNavigateToNextEntry()) {
        navigateToNextEntry();
      }
    };

    document.addEventListener("keydown", kbListener);

    return () => {
      document.removeEventListener("keydown", kbListener);
    };

  }, [currentEntry]);

  return (
    <div id="embedded-gallery-overlay">
      <div class={`album-container`}>
        <AsyncImage src={entries[thumbToIndexMap[currentEntry]].web} />
      </div>
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
  );
};

export default EmbeddedGallery;