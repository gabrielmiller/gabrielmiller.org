import { render } from 'preact';
import AlbumViewer from './AlbumViewer';

render(<AlbumViewer/>, document.getElementById('app-mount')!)

document.getElementById("initial-loader")!.remove();