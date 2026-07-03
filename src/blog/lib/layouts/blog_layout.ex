defmodule Blog.BlogLayout do
  use Tableau.Layout, layout: Blog.RootLayout
  use Phoenix.Component

  def template(assigns) do
    ~H"""
    <div class="container">
    <nav>
        <div>L. Gabriel Miller</div>
        <input id="nav-toggle-state" style="display:none;" type="checkbox" />

        <label id="nav-toggle" htmlFor="nav-toggle-state" role="button">
            <svg viewBox="0 0 100 80" width="40" height="40">
                <rect width="100" height="20"></rect>
                <rect y="30" width="100" height="20"></rect>
                <rect y="60" width="100" height="20"></rect>
            </svg>
        </label>
        <ul>
            <li>
                <a href="/">About</a>
            </li>
            <li >
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
end
