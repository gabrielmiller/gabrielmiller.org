import * as React from "react"
import type { PageProps } from "gatsby"
import { graphql } from 'gatsby'
import Header from "../partials/head"
import { IRecipe, IRecipeIngredient, RecipeUnit } from "../services/recipe"

interface IRecipeContainer {
    markdownRemark: IRecipe
}

export const Head = Header
const RecipePage: React.FC<PageProps<IRecipeContainer>> = ({ data }) => {
    const recipe: IRecipe = data.markdownRemark;
    const [multiplier, setMultiplier] = React.useState(1);

    const getAmount = (ingredient: IRecipeIngredient) => {
        let unit: string = '';

        if (ingredient.unit !== RecipeUnit.Whole) {
            unit = `${ingredient.unit}`;
        }

        const isFraction = ingredient.denominator !== null;
        const denominator = ingredient.denominator ?? 1;
        const numerator = ingredient.numerator * multiplier;

        if (isFraction) {
            const hasLeadingValue = numerator > denominator;
            let leadingNumber: number|string;
            let hasRemainder: boolean = true;
            if (hasLeadingValue) {
                leadingNumber = Math.floor(numerator/denominator);
                hasRemainder = numerator % denominator !== 0;
            } else {
                leadingNumber = '';
            }

            return (
                <>
                    <span className="leading-number">{leadingNumber}</span>
                    { hasRemainder &&
                        <span className="fraction">
                            <sup>{numerator % denominator}</sup>
                            <sub>{denominator}</sub>
                        </span>
                    }
                    &nbsp;
                    <span>{unit}</span>
                </>
            )
        }

        return (
            <>
                <span className="leading-number">{numerator}</span>
                { (unit !== '') &&
                    <>&nbsp;<span>{unit}</span></>
                }
            </>
        );
    }

    return (
        <div className="container">
            <nav>
                <div>
                    <a href="/recipes.html">Recipes</a> &gt;&nbsp;
                    { recipe.frontmatter.category } &gt;&nbsp;
                    { recipe.frontmatter.title }
                </div>
                
            </nav>
            <main>
                <div>
                    <h3>Preparation</h3>
                    <span>I am preparing <input onChange={(e) => setMultiplier(Number(e.target.value))} type="number" value={multiplier}/> X the recipe.</span>
                    <h3>Ingredients</h3>
                    <ul style={{ listStyle: 'none' }}>
                        { recipe.frontmatter.ingredients.map(ingredient =>
                            <li style={{height: '2.5em'}}>
                                
                                { getAmount(ingredient) }&nbsp;
                                <span> 
                                    {ingredient.name}
                                </span>
                            </li>
                        )}
                    </ul>
                </div>
                <h3>Directions</h3>
                <article dangerouslySetInnerHTML={{ __html: recipe.html }}></article>
            </main>
        </div>
    )
}

export const query = graphql`
query ($id: String!) {
    markdownRemark(
        id: { eq: $id },
        fields: { type: { eq: "recipes" }}
    ) {
        html
        frontmatter {
            title
            date
            category
            ingredients {
                denominator
                name
                numerator
                unit
            }
        }
    }
}
`

export default RecipePage