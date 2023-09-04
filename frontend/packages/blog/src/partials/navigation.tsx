import * as React from "react"

interface INavigationProps {
    activeNavItem: string;
}

const Navigation = ({activeNavItem}: INavigationProps) => (
    <nav>
        <div>L. Gabriel Miller</div>
        <input id="nav-toggle-state" style={{ display: 'none'} as React.CSSProperties} type="checkbox"></input>
        <label id="nav-toggle" htmlFor="nav-toggle-state" role="button">
            <svg viewBox="0 0 100 80" width="40" height="40">
                <rect width="100" height="20"></rect>
                <rect y="30" width="100" height="20"></rect>
                <rect y="60" width="100" height="20"></rect>
            </svg>
        </label>
        <ul>
            <li className={activeNavItem === 'about' ? "active" : ""}>
                <a href="/">About</a>
            </li>
            <li className={activeNavItem === 'blog' ? "active" : ""}>
                <a href="/archive.html">Blog</a>
            </li>
            <li>
                <a href="https://github.com/gabrielmiller/">Github</a>
            </li>
        </ul>
    </nav>
)

export default Navigation