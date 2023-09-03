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

    const articlesByTag: IArticlesByPropertyMap = {}
    for (const article of articles) {
        if (article.frontmatter.tags === null) {
            continue
        }
        for (const tag of article.frontmatter.tags) {
            if (!(tag in articlesByTag)) {
                articlesByTag[tag] = []
            }
            articlesByTag[tag].push(article)
        }
    }
    const tags = Object.keys(articlesByTag).sort() as string[]

    return (
        <div className="container">
            <Navigation activeNavItem='blog' />
            <main>
                <p className="callout warning">
                    Please pardon the appearance! I have not decided how I want this to page to be laid out yet. Its current form is a temporary solution.
                </p>
                <h1>Articles</h1>
                <h2>By tag</h2>
                {tags.map((tag, index) =>
                    <>
                        <label htmlFor={'articles-by-'+tag}>
                            <h3 id={dasherize(tag)}>{tag}</h3>
                        </label>
                        <input
                            className="toggle-switch"
                            id={'articles-by-'+tag}
                            style={{ display: 'none'} as React.CSSProperties}
                            type="checkbox"
                            {...{ checked:index === 0 /* note: js is stripped from resulting page so this will result in a usable checkbox element */ }}>
                        </input>
                        <ul>
                        {articlesByTag[tag].map((article) => 
                            <li>
                                <a href={`/posts/${article.frontmatter.slug}.html`}>
                                    {article.frontmatter.date} - {article.frontmatter.title}
                                </a>
                            </li>
                        )}
                        </ul>
                    </>
                )}

                <h2>By year</h2>
                {years.map((year, index) =>
                    <>
                        <label htmlFor={'articles-from-'+year}>
                            <h3 id={year}>{year}</h3>
                        </label>
                        <input
                            className="toggle-switch"
                            id={'articles-from-'+year}
                            style={{ display: 'none'} as React.CSSProperties}
                            type="checkbox"
                            {...{ checked:index === 0 /* ditto */ }}>
                        </input>
                        
                        <ul>
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
    allMarkdownRemark(sort: {frontmatter: {date: DESC}}) {
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