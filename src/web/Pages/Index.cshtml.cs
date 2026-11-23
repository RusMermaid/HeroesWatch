using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace HeroesWatch.Web.Pages;

public sealed class IndexModel : PageModel
{
    private static readonly IReadOnlyList<NewsArticle> PublishedArticles = [];

    public GameVersion? SelectedGame { get; private set; }

    public IReadOnlyList<NewsArticle> Articles { get; private set; } = [];

    public string Heading => SelectedGame is null ? "News" : $"{SelectedGame.Label} News";

    public IActionResult OnGet([FromRoute] int? version, [FromQuery] string? game)
    {
        if (version is null)
        {
            var legacyGame = GameVersion.Supported.FirstOrDefault(option =>
                string.Equals(option.LegacySlug, game, StringComparison.OrdinalIgnoreCase));
            if (legacyGame is not null)
            {
                return RedirectToPage("/Heroes", new { version = legacyGame.Number });
            }

            Articles = PublishedArticles;
            return Page();
        }

        SelectedGame = GameVersion.Supported.First(option => option.Number == version);
        var gameCode = SelectedGame.Code;
        Articles = PublishedArticles
            .Where(article => article.GameCodes.Contains(gameCode, StringComparer.OrdinalIgnoreCase))
            .ToArray();

        return Page();
    }

    public sealed record NewsArticle(string Title, string Summary, IReadOnlyList<string> GameCodes);
}
