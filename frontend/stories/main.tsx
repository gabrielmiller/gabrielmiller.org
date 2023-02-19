import { render } from 'preact';
import StoryViewer from './StoryViewer';

render(<StoryViewer/>, document.getElementById('app-mount')!)

document.getElementById("initial-loader")!.remove();