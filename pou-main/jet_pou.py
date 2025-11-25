import pygame
import random
from constants import SCREEN_HEIGHT, JET_POU_SOUND, GAME_OVER_SOUND, JETPACK_SOUND
from minigames_functions import draw_game_over_menu, draw_score, play_sound, stop_sound


class JetPouGame:
    jet_pou_background = pygame.image.load("jet_pou/jet_pou_background.png")
    jet_pou_grass = pygame.image.load("jet_pou/jet_pou_grass.png")
    jet_pou_tree_upper = pygame.image.load("jet_pou/tree_upper.png")
    jet_pou_tree_lower = pygame.image.load("jet_pou/tree_lower.png")
    jetpack = pygame.image.load("jet_pou/jetpack.png")
    pou_width, pou_height = 50, 50

    def __init__(self, screen):
        self.screen = screen
        self.x = 200
        self.y = 100
        self.background_rect = self.jet_pou_background.get_rect()
        self.grass_rect = self.jet_pou_grass.get_rect()
        self.score = 0
        self.gravity = 1
        self.jump_strength = -5
        self.upper_trees_list = []
        for i in range(1000, 2201, 400):
            self.upper_trees_list.append(
                pygame.Rect(i, random.randint(-400, 0), self.jet_pou_tree_upper.get_width(),
                            self.jet_pou_tree_upper.get_height()))
        self.lower_trees_list = []
        for i in range(len(self.upper_trees_list)):
            self.lower_trees_list.append(
                pygame.Rect(self.upper_trees_list[i][0], self.upper_trees_list[i].y + 580,
                            self.jet_pou_tree_lower.get_width(), self.jet_pou_tree_lower.get_height()))
        self.can_jump = True
        self.is_game_over = False

    def draw_game(self, skin, audio_enabled):
        skin = pygame.transform.scale(skin, (self.pou_width, self.pou_height))
        if self.is_game_over:
            self.screen.blit(self.jet_pou_background, (0, 0))
            self.screen.blit(self.jet_pou_grass, (0, SCREEN_HEIGHT - self.jet_pou_grass.get_height()))
            draw_game_over_menu(self.screen, self.score)

            # enter key to start again
            keys_pressed = pygame.key.get_pressed()
            if keys_pressed[pygame.K_RETURN]:
                self.set_starting_values()

            # escape key to return to main menu
            if keys_pressed[pygame.K_ESCAPE]:
                self.set_starting_values()
                return "minigames"
        else:
            if not pygame.mixer.get_busy():
                play_sound(JET_POU_SOUND, audio_enabled)
            self.draw_moving_background()
            self.draw_moving_grass()
            self.draw_trees(audio_enabled)
            self.draw_pou(skin, audio_enabled)

            draw_score(self.screen, self.score)

            # escape key to return to main menu
            keys_pressed = pygame.key.get_pressed()
            if keys_pressed[pygame.K_ESCAPE]:
                self.set_starting_values()
                stop_sound(JET_POU_SOUND, audio_enabled)
                return "minigames"

    def draw_moving_background(self):
        self.screen.blit(self.jet_pou_background, (self.background_rect.x, 0))
        self.background_rect.x -= 1
        if self.background_rect.x == -1200:
            self.background_rect.x = 0

    def draw_moving_grass(self):
        self.screen.blit(self.jet_pou_grass, (self.grass_rect.x, SCREEN_HEIGHT - self.jet_pou_grass.get_height()))
        self.grass_rect.x -= 2
        if self.grass_rect.x == -1200:
            self.grass_rect.x = 0

    def draw_pou(self, skin, audio_enabled):
        # draw jetpack and skin
        self.jetpack = pygame.transform.scale(self.jetpack, (self.pou_width - 15, self.pou_height - 20))
        self.screen.blit(self.jetpack, (self.x - 20, self.y))
        self.screen.blit(skin, (self.x, self.y))

        # jumping
        keys_pressed = pygame.key.get_pressed()
        if keys_pressed[pygame.K_SPACE] and self.can_jump and self.y > 20:
            play_sound(JETPACK_SOUND, audio_enabled)
            self.gravity = self.jump_strength
            self.can_jump = False

        # falling
        self.y += self.gravity
        self.gravity += 0.15

        # reset jump availability when space is released
        if not keys_pressed[pygame.K_SPACE]:
            self.can_jump = True

        # game over if pou falls off the screen
        if self.y > 550:
            self.is_game_over = True
            play_sound(GAME_OVER_SOUND, audio_enabled)
            stop_sound(JET_POU_SOUND, audio_enabled)

    def draw_trees(self, audio_enabled):
        # draw upper trees, add score and upper and lower trees if a tree goes off the screen
        for tree in self.upper_trees_list:
            tree.x -= 2
            self.screen.blit(self.jet_pou_tree_upper, (tree.x, tree.y))
            if tree.x < -1 * self.jet_pou_tree_upper.get_width():
                self.upper_trees_list.remove(tree)
                self.upper_trees_list.append(
                    pygame.Rect(self.upper_trees_list[-1].x + 400, random.randint(-400, 0),
                                self.jet_pou_tree_upper.get_width(), self.jet_pou_tree_upper.get_height()))
                self.lower_trees_list.append(
                    pygame.Rect(self.upper_trees_list[-1].x, self.upper_trees_list[-1].y + 600,
                                self.jet_pou_tree_lower.get_width(), self.jet_pou_tree_lower.get_height()))
                self.score += 1

            # game over if pou collides with any of upper trees
            if tree.colliderect(pygame.Rect(self.x, self.y + 10, self.pou_width, self.pou_height - 20)):
                self.is_game_over = True
                play_sound(GAME_OVER_SOUND, audio_enabled)
                stop_sound(JET_POU_SOUND, audio_enabled)

        # draw lower trees
        for tree in self.lower_trees_list:
            tree.x -= 2
            self.screen.blit(self.jet_pou_tree_lower, (tree.x, tree.y))
            if tree.x < -1 * self.jet_pou_tree_lower.get_width():
                self.lower_trees_list.remove(tree)

            # game over if pou collides with any of lower trees
            if tree.colliderect(pygame.Rect(self.x, self.y + 10, self.pou_width, self.pou_height - 20)):
                self.is_game_over = True
                play_sound(GAME_OVER_SOUND, audio_enabled)
                stop_sound(JET_POU_SOUND, audio_enabled)

    def set_starting_values(self):
        self.y = 100
        self.background_rect = self.jet_pou_background.get_rect()
        self.grass_rect = self.jet_pou_grass.get_rect()
        self.score = 0
        self.gravity = 1
        self.jump_strength = -5
        self.upper_trees_list = []
        for i in range(1000, 2201, 400):
            self.upper_trees_list.append(
                pygame.Rect(i, random.randint(-400, 0), self.jet_pou_tree_upper.get_width(),
                            self.jet_pou_tree_upper.get_height()))
        self.lower_trees_list = []
        for i in range(len(self.upper_trees_list)):
            self.lower_trees_list.append(
                pygame.Rect(self.upper_trees_list[i][0], self.upper_trees_list[i].y + 580,
                            self.jet_pou_tree_lower.get_width(), self.jet_pou_tree_lower.get_height()))
        self.can_jump = True
        self.is_game_over = False
