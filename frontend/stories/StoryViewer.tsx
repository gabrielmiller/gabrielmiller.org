import { FunctionComponent } from 'preact';
import { useEffect, useState } from 'preact/hooks';
import AsyncImage from './AsyncImage';
import IconScroll from './IconScroll';
import IconToggleOff from './IconToggleOff';
import IconToggleOn from './IconToggleOn';

interface IStoryEntry {
    filename: string;
    isLoaded: boolean;
    metadata: any;
    url?: string;
}

const StoryViewer: FunctionComponent = () => {
    const [storyTitle, setStoryTitle] = useState('');
    const [storyToken, setStoryToken] = useState('');
    const [isIndexLoaded, setIsIndexLoaded] = useState(false);
    const [isIndexLoading, setIsIndexLoading] = useState(false);
    const [index, setIndex] = useState<IStoryEntry[]>([]);
    const [currentEntryIndex, setCurrentEntryIndex] = useState(0);
    const [isPageLoading, setIsPageLoading] = useState(false);
    const [isFullscreenEnabled, setIsFullscreenEnabled] = useState(false);

    const apiDomain = "https://api."+window.location.host;
    const entriesPerPage = 4;

    const getBasicAuthHeader = (): string => {
        return 'Basic '+btoa(storyTitle+":"+storyToken);
    }

    const loadIndex = (event) => {
        event.preventDefault();

        setIsIndexLoading(true);

        const headers = new Headers();
        headers.append('Authorization', getBasicAuthHeader());
        fetch(`${apiDomain}/story`, { method: 'GET', headers }).then(function(response) {
            if (response.status !== 200) {
                return;
            }

            response.json().then((body) => {
                const index: IStoryEntry[] = [];
                for (const entry of body) {
                    entry.isLoaded = false;
                    index.push(entry);
                }
                setIndex(index);
                setIsIndexLoaded(true);
            });
        }).finally(() => {
            setIsIndexLoading(false);
        });
    };

    const loadPage = () => {
        let entryIndex = currentEntryIndex+1;
        setIsPageLoading(true);
        const headers = new Headers();
        headers.append('Authorization', getBasicAuthHeader());
        fetch(`${apiDomain}/entries?page=${Math.ceil(entryIndex/entriesPerPage)}&perPage=${entriesPerPage}`, { method: 'GET', headers }).then(function(response) {
            if (response.status !== 200) {
                return;
            }

            response.json().then((body) => {
                const newIndex = [...index];

                for (const url of body) {
                    newIndex[entryIndex-1].url = url;
                    newIndex[entryIndex-1].isLoaded = true;
                    entryIndex++;
                }

                setIndex(newIndex);
            });
        }).finally(() => {
            setIsPageLoading(false);
        });
    };

    const navigateToNextEntry = () => {
        setCurrentEntryIndex(currentEntryIndex+1);
    };

    const navigateToPrevEntry = () => {
        setCurrentEntryIndex(currentEntryIndex-1);
    };

    const validateCanNavigateToNextEntry = (): boolean => {
        return currentEntryIndex !== (index.length-1);
    };

    const validateCanNavigateToPrevEntry = (): boolean => {
        return currentEntryIndex != 0;
    };

    useEffect(() => {
        if (isIndexLoaded && !isPageLoading && !index[currentEntryIndex].isLoaded) {
            loadPage();
        }

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

    }, [currentEntryIndex, isIndexLoaded]);

    return (
        <div class="story-viewer">
            {!isIndexLoaded && !isIndexLoading && (
                <form onSubmit={loadIndex}>
                    <input
                        autoFocus
                        id="story-title"
                        onChange={(e) => setStoryTitle((e.target as HTMLInputElement).value)}
                        placeholder="Enter story title"
                        type="text">
                    </input>
                    <input
                        id="story-token"
                        onChange={(e) => setStoryToken((e.target as HTMLInputElement).value)}
                        placeholder="Enter token"
                        type="text">
                    </input>
                    <button disabled={isIndexLoading} type="submit">View content &gt;</button>
                </form>
            )}

            {!isIndexLoaded && isIndexLoading && (
                <span class="loader"></span>
            )}

            {isIndexLoaded && (
                <>
                    <div class="toggle-container p-a" onClick={() => setIsFullscreenEnabled(!isFullscreenEnabled)}>
                        {isFullscreenEnabled ? <IconToggleOff /> : <IconToggleOn /> }
                        <span>Full screen</span>
                    </div>
                    <div class="icon-scrollable-container p-a">
                        <IconScroll />
                    </div>
                    <div class={isFullscreenEnabled ? 'story-container fullheight p-a' : 'story-container maxwidth p-a'}>
                        {!('url' in index[currentEntryIndex]) && (
                            <span class="loader"></span>
                        )}
                        {('url' in index[currentEntryIndex]) && (
                            <AsyncImage src={index[currentEntryIndex].url} />
                        )}
                    </div>
                    <div class="navigation p-a">
                        <button disabled={!validateCanNavigateToPrevEntry()} onClick={() => navigateToPrevEntry()} type="button">&lt; Prev</button>
                        <span>{currentEntryIndex+1} of {index.length}</span>
                        <button disabled={!validateCanNavigateToNextEntry()} onClick={() => navigateToNextEntry()} type="button">Next &gt;</button>
                    </div>
                </>
            )}
        </div>
    );
};

export default StoryViewer;