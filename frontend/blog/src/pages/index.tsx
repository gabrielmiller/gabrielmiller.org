import * as React from "react"
import type { HeadFC, PageProps } from "gatsby"
import { graphql } from 'gatsby'
import { IPost } from "../services/post";

const IndexPage: React.FC<PageProps> = ({ data }) => {
  const articles: IPost[] = (data as any).allMarkdownRemark.nodes;

  return (
    <div>
      <h2>Articles</h2>
      <ul>
        {articles.map((article) => 
          <li>
            <a href={`/posts/${article.frontmatter.slug}`}>
              [{article.frontmatter.date}] {article.frontmatter.title}
            </a>
          </li>
        )}
      </ul>
    </div>
  )
}

export default IndexPage

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