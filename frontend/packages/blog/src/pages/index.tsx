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
            <Navigation />
            <main>
                <p>
                    Check out my most recent article:
                    <br />
                    <ul>
                        <li>
                            <a href={`/posts/${mostRecentPost.frontmatter.slug}.html`}>
                                [{mostRecentPost.frontmatter.date}] {mostRecentPost.frontmatter.title}
                            </a>
                        </li>
                    </ul>
                </p>
                <p>
                    Rest of content will go here
                </p>
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