using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace HeroesWatch.Web.Pages;

public sealed class BoardsModel : PageModel
{
    public static IReadOnlyList<Board> Boards { get; } =
    [
        new("general", "General discussion", "Game talk and community news from across the Heroes series."),
        new("strategy", "Strategy & tactics", "Campaign advice, faction strategies, and multiplayer tactics."),
        new("fan-projects", "Fan projects", "Fan-made maps, mods, campaigns, and artwork.")
    ];

    public Board? SelectedBoard { get; private set; }

    public IActionResult OnGet([FromRoute] string? board)
    {
        if (board is null)
        {
            return Page();
        }

        SelectedBoard = Boards.FirstOrDefault(entry =>
            string.Equals(entry.Slug, board, StringComparison.OrdinalIgnoreCase));

        return SelectedBoard is null ? NotFound() : Page();
    }

    public sealed record Board(string Slug, string Title, string Description);
}
