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
  date: string,
  label: string,
  original: string,
  thumb1x: string,
  thumb2x: string,
  thumb4x: string,
  video?: string,
  web: string
}

interface IEntryMap {
  [key: string]: number
}

const clickableElements = new Set([
  "BUTTON",
  "SVG",
  "PATH",
  "IMG"
])

const EmbeddedGallery: FunctionComponent<IEmbeddedGalleryProps> = ({ currentEntry, entries, incrementer }) => {
  const [currentEntryIndex, setCurrentEntryIndex] = useState(0);
  const [isVisible, setIsVisible] = useState(false);
  const [thumbToIndexMap, setThumbToIndexMap] = useState<IEntryMap>({});
  const isActive = () => {
    return currentEntry !== undefined;
  }

  const closeGallery = (event: any) => {
    setIsVisible(false)
    event.preventDefault();
  }

  const maybeCloseGallery = (event: any) => {
    const targetTag = event.target?.tagName;
    if (targetTag === null || targetTag == undefined) {
      return;
    }

    if (clickableElements.has(targetTag.toUpperCase())) {
      return;
    }

    closeGallery(event);
  }

  const navigateToNextEntry = (event: any) => {
    event.preventDefault();
    setCurrentEntryIndex(currentEntryIndex + 1);
  };

  const navigateToPrevEntry = (event: any) => {
    event.preventDefault();
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
      entryMap[entries[i].thumb1x] = i;
    }

    setThumbToIndexMap(entryMap);
  }, []);

  useEffect(() => {
    if (isActive()) {
      const currentEntryIndex = thumbToIndexMap[currentEntry];
      setCurrentEntryIndex(currentEntryIndex);
    }
  }, [currentEntry]);

  useEffect(() => {
    const keyboardListener = (event: any) => {
      if (event.code === "Escape") {
        setIsVisible(false);
      } else if (event.code === "ArrowLeft" && validateCanNavigateToPrevEntry()) {
        navigateToPrevEntry(event);
      } else if (event.code === "ArrowRight" && validateCanNavigateToNextEntry()) {
        navigateToNextEntry(event);
      }
    };

    document.addEventListener("keydown", keyboardListener);

    return () => {
      document.removeEventListener("keydown", keyboardListener);
    };

  }, [currentEntryIndex]);

  useEffect(() => {
    if (!isActive()) {
      return
    }
    setIsVisible(true);
  }, [incrementer])

  return (
    <div>
      <div class={isVisible ? "visible" : "hidden"} id="embedded-gallery-backdrop"></div>
      <div class={isVisible ? "visible" : "hidden"} id="embedded-gallery-overlay" onClick={(event) => maybeCloseGallery(event)}>
        {isActive() &&
          <div class="gallery-container">
            <div class="image-container">
              <AsyncImage src={entries[currentEntryIndex].web} />
            </div>
            <button
              class="control-close-viewer"
              onClick={(event) => closeGallery(event)}
              title="Close viewer"
              type="button">
              <IconXMarkCircle />
            </button>
            <button
              class="control-navigate-previous"
              disabled={!validateCanNavigateToPrevEntry()}
              onClick={(event) => navigateToPrevEntry(event)}
              title="Navigate to previous entry"
              type="button">
              <IconArrowLeftCircle />
            </button>
            <button
              class="control-navigate-next"
              disabled={!validateCanNavigateToNextEntry()}
              onClick={(event) => navigateToNextEntry(event)}
              title="Navigate to next entry"
              type="button">
              <IconArrowRightCircle />
            </button>
          </div>
        }
      </div>
    </div>
  );
};

export default EmbeddedGallery;