const path = require("path");
const _ = require("lodash");

const { createFilePath } = require(`gatsby-source-filesystem`)

exports.onCreateNode = ({ node, getNode, actions }) => {
    const { createNodeField } = actions
    if (node.internal.type === `MarkdownRemark`) {
        const slug = createFilePath({ node, getNode, basePath: `posts` })
        createNodeField({
            node,
            name: `slug`,
            value: `${node.frontmatter.date}/${node.frontmatter.slug}.html`,
        })
    }
}

exports.createPages = async ({ actions, graphql, reporter }) => {
    const { createPage } = actions;

    const tagTemplate = path.resolve("src/templates/tag.tsx")

    const result = await graphql(`
    {
        allMarkdownRemark {
          distinct(field: {frontmatter: {tags: SELECT}})
        }
        markdownRemark {
          frontmatter {
            tags
          }
        }
      }
    `)

    result.data.allMarkdownRemark.distinct.forEach(tag => {
        createPage({
            path: `/tags/${_.kebabCase(tag)}.html`,
            component: tagTemplate,
            context: {
                tag: tag,
            },
        })
    })
}
