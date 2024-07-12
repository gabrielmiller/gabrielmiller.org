const path = require("path");
const _ = require("lodash");

exports.onCreateNode = ({ node, getNode, actions }) => {
    // Set a `type` property to use for filtering
    // different types of ingested markdown data.
    if (node.internal.type === `MarkdownRemark`) {
        const { createNodeField } = actions;

        createNodeField({
            node,
            name: `type`,
            value: getNode(node.parent).sourceInstanceName,
        })
    }
}

exports.createPages = async ({ actions, graphql }) => {
    const { createPage } = actions;

    const tagTemplate = path.resolve("src/templates/tag.tsx")
    const tagQuery = await graphql(`
    {
      allMarkdownRemark(
        filter: { fields: { type: { eq: "posts" }}}
      ) {
        distinct(field: { frontmatter: { tags: SELECT }})
      }
      markdownRemark {
        frontmatter {
          tags
        }
      }
    }
    `)
    tagQuery.data.allMarkdownRemark.distinct.forEach(tag => {
        createPage({
            path: `/tags/${_.kebabCase(tag)}.html`,
            component: tagTemplate,
            context: {
                tag: tag,
            },
        })
    })

    const postTemplate = path.resolve("src/templates/post.tsx")
    const postQuery = await graphql(`
    {
      allMarkdownRemark(filter: { fields: { type: { eq: "posts" }}}) {
        nodes {
          id
          frontmatter {
            slug
          }
        }
      }
    }
    `)
    postQuery.data.allMarkdownRemark.nodes.forEach(post => {
      createPage({
        path: `/posts/${post.frontmatter.slug}.html`,
        component: postTemplate,
        context: {
          id: post.id
        }
      })
    })

    const recipeTemplate = path.resolve("src/templates/recipe.tsx")
    const recipeQuery = await graphql(`
    {
      allMarkdownRemark(filter: { fields: { type: { eq: "recipes" }}}) {
        nodes {
          id
          frontmatter {
            slug
          }
        }
      }
    }
    `)
    recipeQuery.data.allMarkdownRemark.nodes.forEach(recipe => {
      createPage({
        path: `/recipes/${recipe.frontmatter.slug}.html`,
        component: recipeTemplate,
        context: {
          id: recipe.id
        }
      })
    })
}
