import React from 'react';
import IconScroll from './IconScroll';
import IconToggleOff from './IconToggleOff';
import IconToggleOn from './IconToggleOn';

interface IStoryEntry {
    filename: string;
    isLoaded: boolean;
    metadata: any;
    url?: string;
}

const StoryViewer: React.FC = () => {
    const [storyTitle, setStoryTitle] = React.useState('');
    const [storyToken, setStoryToken] = React.useState('');
    const [isIndexLoaded, setIsIndexLoaded] = React.useState(false);
    const [isIndexLoading, setIsIndexLoading] = React.useState(false);
    const [index, setIndex] = React.useState<IStoryEntry[]>([]);
    const [currentEntryIndex, setCurrentEntryIndex] = React.useState(0);
    const [isPageLoading, setIsPageLoading] = React.useState(false);
    const [isFullscreenEnabled, setIsFullscreenEnabled] = React.useState(false);

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

    React.useEffect(() => {
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
        <div className="story-viewer">
            {!isIndexLoaded && !isIndexLoading && (
                <form onSubmit={loadIndex}>
                    <input
                        autoFocus
                        id="story-title"
                        onChange={(e) => setStoryTitle(e.target.value)}
                        placeholder="Enter story title"
                        type="text">
                    </input>
                    <input
                        id="story-token"
                        onChange={(e) => setStoryToken(e.target.value)}
                        placeholder="Enter token"
                        type="text">
                    </input>
                    <button disabled={isIndexLoading} type="submit">View content &gt;</button>
                </form>
            )}

            {!isIndexLoaded && isIndexLoading && (
                <span className="loader"></span>
            )}

            {isIndexLoaded && (
                <>
                    <div className="toggle-container p-a" onClick={() => setIsFullscreenEnabled(!isFullscreenEnabled)}>
                        {isFullscreenEnabled ? <IconToggleOff /> : <IconToggleOn /> }
                        <span>Full screen</span>
                    </div>
                    <IconScroll />
                    <div className={isFullscreenEnabled ? 'story-container fullheight' : 'story-container'}>
                        {!('url' in index[currentEntryIndex]) && (
                            <span className="loader"></span>
                        )}
                        {('url' in index[currentEntryIndex]) && (
                            <img src={index[currentEntryIndex].url}></img>
                        )}
                    </div>
                    <div className="navigation">
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