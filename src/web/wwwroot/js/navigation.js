const gamesMenu = document.querySelector(".heroes-menu");
const gamesToggle = gamesMenu.querySelector("summary");

document.addEventListener("click", (event) => {
    if (gamesMenu.open && !gamesMenu.contains(event.target)) {
        gamesMenu.open = false;
    }
});

document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && gamesMenu.open) {
        gamesMenu.open = false;
        gamesToggle.focus();
    }
});
