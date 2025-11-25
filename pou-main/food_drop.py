import pygame
import random
from food_images import food_images_list
from trash_images import trash_images_list
from minigames_functions import draw_game_over_menu, draw_score, play_sound, stop_sound
from constants import CHARACTER_WIDTH, CHARACTER_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT, FOOD_IMAGE_WIDTH, \
    FOOD_IMAGE_HEIGHT, SMALL_FONT, FOOD_DROP_SOUND, EAT_SOUND, GAME_OVER_SOUND


class FoodDropGame:
    food_drop_background = pygame.image.load("food_drop/food_drop_background.png")
    character_vel = 15

    def __init__(self, screen):
        self.screen = screen
        self.x = 550
        self.y = 380
        self.score = 0
        self.missed = 0
        self.food_vel = 3
        self.food_list = []
        self.trash_list = []
        self.is_game_over = False

    def draw_game(self, skin, audio_enabled):
        self.screen.blit(self.food_drop_background, (0, 0))

        if self.is_game_over:
            # draw game over prompts
            draw_game_over_menu(self.screen, self.score)

            # enter key to start again
            keys_pressed = pygame.key.get_pressed()
            if keys_pressed[pygame.K_RETURN]:
                self.set_starting_values()

            # escape key to return to main menu
            if keys_pressed[pygame.K_ESCAPE]:
                self.set_starting_values()
                return "minigames"

        # draw the game if not game over
        else:
            if not pygame.mixer.get_busy():
                play_sound(FOOD_DROP_SOUND, audio_enabled)
            self.keys_handler()
            self.screen.blit(skin, (self.x, self.y))
            self.draw_food(audio_enabled)
            self.draw_trash(audio_enabled)
            draw_score(self.screen, self.score)
            missed_text = SMALL_FONT.render(f"Missed: {self.missed}/5", True, "black")
            self.screen.blit(missed_text, (SCREEN_WIDTH - missed_text.get_width() - 50, 50))

            # escape key to return to main menu
            keys_pressed = pygame.key.get_pressed()
            if keys_pressed[pygame.K_ESCAPE]:
                self.set_starting_values()
                stop_sound(FOOD_DROP_SOUND, audio_enabled)
                return "minigames"

    # pou movement
    def keys_handler(self):
        keys_pressed = pygame.key.get_pressed()
        if keys_pressed[pygame.K_d] and self.x < SCREEN_WIDTH - CHARACTER_WIDTH:
            self.x += self.character_vel
        if keys_pressed[pygame.K_a] and self.x > 0:
            self.x -= self.character_vel

    def draw_food(self, audio_enabled):
        # add new food
        if len(self.food_list) < 2:
            food_image = food_images_list[random.randint(0, len(food_images_list) - 1)]
            new_food = pygame.Rect(random.randint(0, SCREEN_WIDTH - FOOD_IMAGE_WIDTH),
                                   random.randint(-1000, -50), FOOD_IMAGE_WIDTH, FOOD_IMAGE_HEIGHT)
            self.food_list.append((new_food, food_image))

        # draw food on screen, remove when goes under the screen or collides with pou, add score or missed points
        for food in self.food_list:
            self.screen.blit(food[1], (food[0].x, food[0].y))
            food[0].y += self.food_vel
            if food[0].y > SCREEN_HEIGHT:
                self.missed += 1
                self.food_list.remove(food)
            if food[0].colliderect(pygame.Rect(self.x, self.y, CHARACTER_WIDTH, CHARACTER_HEIGHT)):
                self.food_list.remove(food)
                self.score += 1
                play_sound(EAT_SOUND, audio_enabled)

        # end the game when pou misses 5 foods
        if self.missed > 4:
            self.is_game_over = True
            play_sound(GAME_OVER_SOUND, audio_enabled)
            stop_sound(FOOD_DROP_SOUND, audio_enabled)

        # increase the food velocity
        self.food_vel = self.score / 5 + 3

    def draw_trash(self, audio_enabled):
        # add new trash
        if len(self.trash_list) < 1:
            trash_image = trash_images_list[random.randint(0, len(trash_images_list) - 1)]
            new_trash = pygame.Rect(random.randint(0, SCREEN_WIDTH - FOOD_IMAGE_WIDTH),
                                    random.randint(-1000, -50), FOOD_IMAGE_WIDTH, FOOD_IMAGE_HEIGHT)
            self.trash_list.append((new_trash, trash_image))

        # draw trash on screen, removes when goes under the screen or collides with pou
        for trash in self.trash_list:
            self.screen.blit(trash[1], (trash[0].x, trash[0].y))
            trash[0].y += self.food_vel
            if trash[0].y > SCREEN_HEIGHT:
                self.trash_list.remove(trash)

            # end the game when pou collides with trash
            if trash[0].colliderect(pygame.Rect(self.x, self.y, CHARACTER_WIDTH, CHARACTER_HEIGHT)):
                self.is_game_over = True
                play_sound(GAME_OVER_SOUND, audio_enabled)
                stop_sound(FOOD_DROP_SOUND, audio_enabled)

    def set_starting_values(self):
        self.x = 550
        self.y = 380
        self.score = 0
        self.missed = 0
        self.food_vel = 3
        self.food_list = []
        self.trash_list = []
        self.is_game_over = False
