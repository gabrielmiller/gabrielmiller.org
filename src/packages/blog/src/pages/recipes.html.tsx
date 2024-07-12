import * as React from "react"
import type { PageProps } from "gatsby"
import { graphql } from 'gatsby'
import Header from "../partials/head"
import { IRecipe } from "../services/recipe"
import dasherize from "../services/dasherize"

interface IIndexContainer {
    allMarkdownRemark: {
        nodes: IRecipe[]
    }
}


export const Head = Header
const RecipesPage: React.FC<PageProps<IIndexContainer>> = ({ data }) => {
    const recipes: IRecipe[] = data.allMarkdownRemark.nodes

    return (
        <div className="container">
            <nav>
                <div>Recipes</div>
            </nav>
            <main>
                <ul className="list">
                    {recipes.map((recipe) =>
                        <li>
                            <a href={`/recipes/${dasherize(recipe.frontmatter.slug)}.html`}>
                                {recipe.frontmatter.title}
                            </a>
                        </li>
                    )}
                </ul>
            </main>
        </div>
    )
}

export const query = graphql`
{
    allMarkdownRemark(
        sort: [
          { frontmatter: { category: ASC }},
          { frontmatter: { title: ASC }}
        ],
        filter: { fields: { type: { eq: "recipes" }}}
    ) {
        nodes {
            frontmatter {
                category
                title
                slug
            }
        }
    }
}
`

export default RecipesPage