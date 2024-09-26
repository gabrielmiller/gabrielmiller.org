import * as React from "react"
import type { PageProps } from "gatsby"
import { graphql } from 'gatsby'
import Header from "../partials/head"
import Navigation from "../partials/navigation"
import { IPost } from "../services/post"
import dasherize from "../services/dasherize"

interface IIndexContainer {
    allMarkdownRemark: {
        nodes: IPost[]
    }
}

interface IArticlesByPropertyMap {
    [tag:string]: IPost[]
}

export const Head = Header
const ArchivePage: React.FC<PageProps<IIndexContainer>> = ({ data }) => {
    const articles: IPost[] = data.allMarkdownRemark.nodes

    const articlesByYear: IArticlesByPropertyMap = {}
    for (const article of articles) {
        const year = parseInt(article.frontmatter.date.substring(0,4));
        if (!(year in articlesByYear)) {
            articlesByYear[year] = []
        }
        articlesByYear[year].push(article)
    }
    const years = Object.keys(articlesByYear).sort().reverse() as string[]
    for (const year of years) {
        articlesByYear[year].sort();
    }

    const Tags: IArticlesByPropertyMap = {}
    for (const article of articles) {
        if (article.frontmatter.tags === null) {
            continue
        }
        for (const tag of article.frontmatter.tags) {
            if (!(tag in Tags)) {
                Tags[tag] = [];
            }
        }
    }
    const tags = Object.keys(Tags).sort() as string[]

    return (
        <div className="container">
            <Navigation activeNavItem='blog' />
            <main>
                <h1>Tags</h1>
                <ul className="list">
                    {tags.map((tag) =>
                        <li>
                            <a href={`/tags/${dasherize(tag)}.html`}>
                                {tag}
                            </a>
                        </li>
                    )}
                </ul>

                <h1>Articles</h1>
                {years.map((year) =>
                    <>
                        <h3 id={year}>{year}</h3>
                        <ul className="list">
                        {articlesByYear[year].map((article) =>
                            <li>
                                <a href={`/posts/${article.frontmatter.slug}.html`}>
                                    {article.frontmatter.date} - {article.frontmatter.title}
                                </a>
                            </li>
                        )}
                        </ul>
                    </>
                )}
            </main>
        </div>
    )
}

export const query = graphql`
{
    allMarkdownRemark(
        sort: { frontmatter: { date: DESC }},
        filter: { fields: { type: { eq: "posts" }}}
    ) {
        nodes {
            frontmatter {
                date
                title
                slug
                tags
            }
            html
        }
    }
}
`

export default ArchivePage