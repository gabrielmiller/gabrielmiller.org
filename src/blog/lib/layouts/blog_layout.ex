defmodule Blog.BlogLayout do
  use Tableau.Layout, layout: Blog.RootLayout
  use Phoenix.Component

  def template(assigns) do
    ~H"""
    <div class="container">
      <nav>
        <div>L. Gabriel Miller</div>
        <input id="nav-toggle-state" style="display:none;" type="checkbox" />

        <label id="nav-toggle" for="nav-toggle-state" role="button">
          <svg viewBox="0 0 100 80" width="40" height="40">
            <rect width="100" height="20"></rect>
            <rect y="30" width="100" height="20"></rect>
            <rect y="60" width="100" height="20"></rect>
          </svg>
        </label>
        <ul>
          <li>
            <a class={maybe_set_active(@page, :about)} href="/">About</a>
          </li>
          <li class={maybe_set_active(@page, :blog)}>
            <a href="/archive.html">Blog</a>
          </li>
          <li>
            <a href="https://github.com/gabrielmiller/">Github</a>
          </li>
          <li>
            <a href="https://gitlab.com/gabrielmiller/">Gitlab</a>
          </li>
          <li>
            <a href="https://www.linkedin.com/in/lgabrielmiller/">LinkedIn</a>
          </li>
        </ul>
      </nav>

      <main>
        {render(@inner_content)}
      </main>
    </div>
    """
  end

  defp maybe_set_active(%{permalink: permalink}, group) do
    active? =
      case group do
        :about -> String.match?(permalink, ~r/\//)
        :blog -> blog_match?(permalink)
        _ -> false
      end

    if active?,
      do: "active",
      else: ""
  end

  defp blog_match?("/archive.html"), do: true

  defp blog_match?(pattern) do
    cond do
      String.match?(pattern, ~r/^\/tags\//) -> true
      String.match?(pattern, ~r/^\/posts\//) -> true
      true -> false
    end
  end
end
