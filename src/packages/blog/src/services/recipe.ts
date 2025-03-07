export interface IRecipe extends IRecipeMeta {
    html: string,
}

export enum RecipeUnit {
  Cup = "cup",
  Teaspoon = "teaspoon",
  Tablespoon = "tablespoon",
  Whole = "whole"
}

export interface IRecipeMeta {
  frontmatter: {
    category: string,
    date: string,
    ingredients: IRecipeIngredient[],
    slug: string,
    title: string
  }
}

export interface IRecipeIngredient {
  category: string,
  name: string,
  numerator: number,
  denominator: number | null,
  unit: RecipeUnit
}