import * as React from "react"
import { PageProps, graphql } from 'gatsby'
import Header from "../partials/head"
import Navigation from "../partials/navigation"
import { IPost } from "../services/post"

interface IMostRecentPostContainer {
    allMarkdownRemark: {
        nodes: IPost[]
    }
}

export const Head = Header
const IndexPage: React.FC<PageProps<IMostRecentPostContainer>> = ({ data }) => {
    const mostRecentPost: IPost = data.allMarkdownRemark.nodes[0];

    return (
        <div className="container">
            <Navigation activeNavItem='about' />
            <main>
                <p className="callout info">
                    Check out my most recent article: <a href={`/posts/${mostRecentPost.frontmatter.slug}.html`}>{mostRecentPost.frontmatter.title}</a>
                    <br />
                </p>
                <img alt="a photo of the author" className="avatar" src="avatar.jpg" />
                <p>👋 Hi there! My name is Gabe. Thanks for visiting my website.</p>
                <p>I'm interested in most things web-development, databases, security, and GIS. I'm a software engineer at <a href="https://www.digitalonboarding.com/">Digital Onboarding</a>. I previously have worked at <a href="https://heggerty.org/">Heggerty</a> and <a href="https://www.jazzhr.com">JazzHR</a>, formerly known as <em>Jazz</em> and before that as <em>The Resumator</em>. I have over 12 years of full-stack web development experience, more recently focused on front-end development, architecture, distributed systems, and data.</p>
                <p>Growing up I played PC games and as a result was exposed to computers at a young and formative age. Despite that I was a late entrant to the software industry. I am a self-taught engineer and earned a degree in environmental studies and a certificate in geographic information systems.</p>
                <p>I am a proponent of open-source software and appreciate its many communities.</p>
                <p>In my free time I enjoy:</p>
                <ul className="emoji-list">
                    <li><span className="emoji">🔧</span>tinkering with personal software projects</li>
                    <li><span className="emoji">🏃</span>recreational endurance sports</li>
                    <li><span className="emoji">🪵</span>woodworking</li>
                    <li><span className="emoji">🍅</span>gardening</li>
                </ul>
                <p>This website is comprised of personal thoughts, work, and projects unless otherwise noted. None of the opinions expressed within represent those of my employer.</p>
                <p>You can find my current resume <a href="lgabrielmiller.pdf">here</a>.</p>
                <p>Page last updated 2025-03-22.</p>
            </main>
        </div>
    )
}

export const query = graphql`
{
    allMarkdownRemark(limit: 1, sort: {frontmatter: {date: DESC}}) {
        nodes {
            frontmatter {
                date
                title
                slug
            }
        }
    }
}
`

export default IndexPage
