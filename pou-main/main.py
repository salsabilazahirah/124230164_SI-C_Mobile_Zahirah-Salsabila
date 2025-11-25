import pygame
from button import Button
from constants import SCREEN_WIDTH, SCREEN_HEIGHT
from food_drop import FoodDropGame
from jet_pou import JetPouGame
from sky_hop import SkyHopGame
from skins_images import default_img, coat_img, panda_img, polo_img, pumpkin_img, t_shirt_img

pygame.init()
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("Pou")
clock = pygame.time.Clock()

BACKGROUND_IMAGE = pygame.image.load("background.png")
bg_img = pygame.transform.scale(BACKGROUND_IMAGE, (SCREEN_WIDTH, SCREEN_HEIGHT))

# start the game with "main menu" state
game_state = "main_menu"

# skin settings
selected_skin = 0
skin_settings = {0: "Default", 1: "Coat", 2: "Panda", 3: "Polo", 4: "Pumpkin", 5: "T-shirt"}
skins = [default_img, coat_img, panda_img, polo_img, pumpkin_img, t_shirt_img]

# audio settings
selected_audio = 1
audio_settings = {1: "On", 0: "Off"}

# create main menu buttons and buttons list
minigames_button = Button(150, screen, "Minigames")
settings_button = Button(250, screen, "Settings")
exit_button = Button(350, screen, "Exit")
main_menu_buttons = [minigames_button, settings_button, exit_button]

# create minigames buttons
food_drop_button = Button(100, screen, "Food Drop")
jet_pou_button = Button(200, screen, "Jet Pou")
sky_hop_button = Button(300, screen, "Sky Hop")
minigames_back_button = Button(400, screen, "Back")
minigames_buttons = [food_drop_button, jet_pou_button, sky_hop_button, minigames_back_button]

# create settings menu buttons
settings_skin = Button(150, screen, f"Skin: {skin_settings[selected_skin]}")
settings_audio = Button(250, screen, f"Audio: {audio_settings[selected_audio]}")
settings_back = Button(350, screen, "Back")
settings_buttons = [settings_skin, settings_audio, settings_back]

# menu state tracking
main_menu_selected_index = 0
settings_selected_index = 0
minigames_selected_index = 0
main_menu_buttons[main_menu_selected_index].set_selected(True)
settings_buttons[settings_selected_index].set_selected(True)
minigames_buttons[minigames_selected_index].set_selected(True)

# dictionary of game states and functions
game_actions = {
    "main_menu": lambda: draw_buttons(main_menu_buttons),
    "minigames": lambda: draw_buttons(minigames_buttons),
    "settings": lambda: draw_buttons(settings_buttons),
    "fooddrop": lambda: handle_game_result(FoodDrop.draw_game(skins[selected_skin], selected_audio)),
    "jetpou": lambda: handle_game_result(JetPou.draw_game(skins[selected_skin], selected_audio)),
    "skyhop": lambda: handle_game_result(SkyHop.draw_game(skins[selected_skin], selected_audio)),
}


# menu navigation
def navigate_menu(buttons, selected_index, key):
    buttons[selected_index].set_selected(False)
    if key == pygame.K_w:
        selected_index = (selected_index - 1) % len(buttons)
    elif key == pygame.K_s:
        selected_index = (selected_index + 1) % len(buttons)
    buttons[selected_index].set_selected(True)
    return selected_index


# draw buttons for each menu
def draw_buttons(buttons):
    for button in buttons:
        button.draw()


# change game state after moving back from a minigame
def handle_game_result(result):
    global game_state
    if result == "minigames":
        game_state = "minigames"


FoodDrop = FoodDropGame(screen)
JetPou = JetPouGame(screen)
SkyHop = SkyHopGame(screen)

running = True
while running:
    # event handling
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        # menu navigation
        elif event.type == pygame.KEYDOWN:
            if game_state == "main_menu":
                # use the navigate_menu function for main menu
                if event.key in (pygame.K_w, pygame.K_s):
                    main_menu_selected_index = navigate_menu(main_menu_buttons, main_menu_selected_index, event.key)
                elif event.key == pygame.K_SPACE:
                    if main_menu_selected_index == 0:
                        game_state = "minigames"
                        minigames_selected_index = 0
                        for button in minigames_buttons:
                            button.set_selected(False)
                        minigames_buttons[minigames_selected_index].set_selected(True)
                    elif main_menu_selected_index == 1:
                        game_state = "settings"
                        settings_selected_index = 0
                        for button in settings_buttons:
                            button.set_selected(False)
                        settings_buttons[settings_selected_index].set_selected(True)
                    elif main_menu_selected_index == 2:
                        running = False
            elif game_state == "minigames":
                if event.key in (pygame.K_w, pygame.K_s):
                    minigames_selected_index = navigate_menu(minigames_buttons, minigames_selected_index, event.key)
                elif event.key == pygame.K_SPACE:
                    if minigames_selected_index == 0:
                        game_state = "fooddrop"
                    elif minigames_selected_index == 1:
                        game_state = "jetpou"
                    elif minigames_selected_index == 2:
                        game_state = "skyhop"
                    elif minigames_selected_index == len(minigames_buttons) - 1:
                        game_state = "main_menu"
            elif game_state == "settings":
                # use the navigate_menu function for settings menu
                if event.key in (pygame.K_w, pygame.K_s):
                    settings_selected_index = navigate_menu(settings_buttons, settings_selected_index, event.key)
                elif event.key == pygame.K_SPACE:
                    if settings_selected_index == 0:
                        selected_skin = (selected_skin - 1) % len(skin_settings)
                        settings_skin = Button(150, screen, f"Skin: {skin_settings[selected_skin]}")
                        settings_buttons = [settings_skin, settings_audio, settings_back]
                        settings_selected_index = navigate_menu(settings_buttons, settings_selected_index, event.key)
                    elif settings_selected_index == 1:
                        selected_audio = (selected_audio + 1) % 2
                        settings_audio = Button(250, screen, f"Audio: {audio_settings[selected_audio]}")
                        settings_buttons = [settings_skin, settings_audio, settings_back]
                        settings_selected_index = navigate_menu(settings_buttons, settings_selected_index, event.key)
                    elif settings_selected_index == len(settings_buttons) - 1:
                        game_state = "main_menu"
                        main_menu_selected_index = 0
                        for button in main_menu_buttons:
                            button.set_selected(False)
                        main_menu_buttons[main_menu_selected_index].set_selected(True)

    screen.blit(bg_img, (0, 0))

    # draw menu buttons
    if game_state in game_actions:
        game_actions[game_state]()

    pygame.display.update()

pygame.quit()
