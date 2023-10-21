import * as React from "react"
import type { PageProps } from "gatsby"
import { graphql } from 'gatsby'
import Header from "../partials/head"
import Navigation from "../partials/navigation"
import { IPostMeta } from "../services/post"

interface ITagPageContext {
    tag: string
}

interface ITagGroup {
    fieldValue: string;
    nodes: IPostMeta[]
}

interface ITagContainer {
    allMarkdownRemark: {
        group: ITagGroup[]
    }
}

export const Head = Header
const TagPage: React.FC<PageProps<ITagContainer, ITagPageContext>> = ({ data, pageContext }) => {

    const getTagNodes = (): IPostMeta[] => {
        return data.allMarkdownRemark.group.filter((group) => group.fieldValue === pageContext.tag)[0].nodes;
    }

    return (
        <div className="container">
            <Navigation activeNavItem='blog' />
            <main>
                <h2>Articles tagged {pageContext.tag}:</h2>
                <ul className="list">
                    { getTagNodes().map((article) =>
                     <li>
                        <a href={`/posts/${article.frontmatter.slug}.html`}>{article.frontmatter.date} - {article.frontmatter.title}</a>
                    </li>
                    )}
                </ul>
            </main>
        </div>
    )
}

export const query = graphql`
{
    allMarkdownRemark {
      group(field: {frontmatter: {tags: SELECT}}) {
        fieldValue
        nodes {
          frontmatter {
            date
            slug
            title
            tags
          }
        }
      }
    }
  }
`

export default TagPage