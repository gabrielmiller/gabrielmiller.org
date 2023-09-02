import * as React from "react"
import type { HeadFC, PageProps } from "gatsby"
import { graphql } from 'gatsby'
import { IPost } from "../services/post"

interface IIndexContainer {
  allMarkdownRemark: {
    nodes: IPost[]
  }
}

const IndexPage: React.FC<PageProps<IIndexContainer>> = ({ data }) => {
  const articles: IPost[] = data.allMarkdownRemark.nodes

  return (
    <div>
      <h2>Articles</h2>
      <ul>
        {articles.map((article) => 
          <li>
            <a href={`/posts/${article.frontmatter.slug}.html`}>
              [{article.frontmatter.date}] {article.frontmatter.title}
            </a>
          </li>
        )}
      </ul>
    </div>
  )
}

export const Head: HeadFC = () => <title>Gabe Miller</title>

export const query = graphql`
{
  allMarkdownRemark {
    nodes {
      frontmatter {
        date
        title
        slug
      }
      html
    }
  }
}
`

export default IndexPage