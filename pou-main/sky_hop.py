import pygame
import random
from constants import SCREEN_WIDTH, SCREEN_HEIGHT, GAME_OVER_SOUND, SKY_HOP_SOUND, JUMP_SOUND
from minigames_functions import draw_score, draw_game_over_menu, play_sound, stop_sound


class SkyHopGame:
    sky_hop_background = pygame.image.load("sky_hop/skyhop_background.png")
    step_image = pygame.image.load("sky_hop/sky_hop_step.png")
    cloud_image = pygame.image.load("sky_hop/sky_hop_cloud.png")
    pou_width, pou_height = 70, 70

    # options for step position in a triple row
    four_step_row_options = {0: (0, 1), 1: (1, 2), 2: (2, 3)}

    # options for step position in a quadruple row
    three_step_row_options = {0: (0, 0), 1: (0, 1), 2: (1, 2), 3: (2, 2)}

    def __init__(self, screen):
        self.screen = screen
        self.x = SCREEN_WIDTH / 2 - self.pou_width / 2
        self.y = 440
        self.score = 0
        self.time_elapsed = 0
        self.game_over = False

        self.move_steps = False
        self.steps_velocity = 17

        self.move_pou = False
        self.pou_velocity = -10
        self.direction = "R"

        # initial steps indexes
        self.triple_row_step_index = 1
        self.quadruple_row_step_index = 1

        # create list of four steps rows
        self.four_steps_list = [
            [{"rect": pygame.Rect(100, 350, 116, 36), "type": "cloud"},
             {"rect": pygame.Rect(400, 350, 116, 36), "type": "cloud"},
             {"rect": pygame.Rect(700, 350, 116, 36), "type": "step"},
             {"rect": pygame.Rect(1000, 350, 116, 36), "type": "cloud"}],
            [{"rect": pygame.Rect(100, 50, 116, 36), "type": "cloud"},
             {"rect": pygame.Rect(400, 50, 116, 36), "type": "step"},
             {"rect": pygame.Rect(700, 50, 116, 36), "type": "cloud"},
             {"rect": pygame.Rect(1000, 50, 116, 36), "type": "cloud"}]

        ]
        # create list of three steps rows
        self.three_steps_list = [
            [{"rect": pygame.Rect(250, 500, 116, 36), "type": "cloud"},
             {"rect": pygame.Rect(550, 500, 116, 36), "type": "step"},
             {"rect": pygame.Rect(850, 500, 116, 36), "type": "cloud"}],
            [{"rect": pygame.Rect(250, 200, 116, 36), "type": "cloud"},
             {"rect": pygame.Rect(550, 200, 116, 36), "type": "step"},
             {"rect": pygame.Rect(850, 200, 116, 36), "type": "cloud"}]
        ]

    def draw_game(self, skin, audio_enabled):
        # draw background, skin, steps
        if self.game_over:
            self.screen.blit(self.sky_hop_background, (0, 0))
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
                play_sound(SKY_HOP_SOUND, audio_enabled)
            self.screen.blit(self.sky_hop_background, (0, 0))
            skin = pygame.transform.scale(skin, (self.pou_width, self.pou_height))
            self.draw_pou(skin, audio_enabled)
            self.draw_steps(audio_enabled)
            draw_score(self.screen, self.score)
            self.draw_time_bar(audio_enabled)

            # return to menu when escape key is pressed
            keys_pressed = pygame.key.get_pressed()
            if keys_pressed[pygame.K_ESCAPE]:
                self.set_starting_values()
                stop_sound(SKY_HOP_SOUND, audio_enabled)
                return "minigames"

    # draw pou function
    def draw_pou(self, skin, audio_enabled):
        self.screen.blit(skin, (self.x, self.y))

        # if a or d key is pressed, make the steps and pou move
        for event in pygame.event.get():
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_d and not self.move_pou:
                    self.move_steps = True
                    self.move_pou = True
                    self.direction = "R"
                    play_sound(JUMP_SOUND, audio_enabled)
                elif event.key == pygame.K_a and not self.move_pou:
                    self.move_steps = True
                    self.move_pou = True
                    self.direction = "L"
                    play_sound(JUMP_SOUND, audio_enabled)
        # move pou
        if self.move_pou:
            self.y += self.pou_velocity
            if self.direction == "R":
                self.x += 7.25
            else:
                self.x -= 7.25

            # increase pou velocity and stop moving pou after reaching the cut-off value
            self.pou_velocity += 1
            if self.pou_velocity == 11:
                self.move_pou = False
                self.pou_velocity = -10
                # add score and time after reaching a step
                self.score += 1
                self.time_elapsed -= 100

        if self.x < -20 or self.x > SCREEN_WIDTH - 30:
            self.game_over = True
            play_sound(GAME_OVER_SOUND, audio_enabled)
            stop_sound(SKY_HOP_SOUND, audio_enabled)

    def draw_steps(self, audio_enabled):
        for row in self.four_steps_list:
            for step in row:
                # check for collision with pou, game over if so
                if step["rect"].colliderect(
                        pygame.Rect(self.x, self.y, self.pou_width, self.pou_height)) and step["type"] == "cloud":
                    self.game_over = True
                    play_sound(GAME_OVER_SOUND, audio_enabled)
                    stop_sound(SKY_HOP_SOUND, audio_enabled)

                # blit four steps rows on the screen
                if step["type"] == "step":
                    self.screen.blit(self.step_image, (step["rect"].x, step["rect"].y))
                else:
                    self.screen.blit(self.cloud_image, (step["rect"].x, step["rect"].y))
        # blit three steps rows on the screen
        for row in self.three_steps_list:
            for step in row:
                # check for collision with pou, game over if so
                if step["rect"].colliderect(
                        pygame.Rect(self.x, self.y, self.pou_width, self.pou_height)) and step["type"] == "cloud":
                    self.game_over = True
                    play_sound(GAME_OVER_SOUND, audio_enabled)
                    stop_sound(SKY_HOP_SOUND, audio_enabled)

                # blit four steps rows on the screen
                if step["type"] == "step":
                    self.screen.blit(self.step_image, (step["rect"].x, step["rect"].y))
                else:
                    self.screen.blit(self.cloud_image, (step["rect"].x, step["rect"].y))

        # add new four steps rows and delete those off the screen
        if self.four_steps_list[0][0]["rect"].y > 600:
            y_position = self.three_steps_list[-1][0]["rect"].y

            # generate new step index based on previous step index in triple row
            new_step_index = random.randint(*self.four_step_row_options[self.triple_row_step_index])

            # add four new clouds in a row
            self.four_steps_list.append([
                {"rect": pygame.Rect(100, y_position - 150, 116, 36), "type": "cloud"},
                {"rect": pygame.Rect(400,  y_position - 150, 116, 36), "type": "cloud"},
                {"rect": pygame.Rect(700, y_position - 150, 116, 36), "type": "cloud"},
                {"rect": pygame.Rect(1000, y_position - 150, 116, 36), "type": "cloud"}])

            # change one of the clouds to step
            self.four_steps_list[-1][new_step_index] = {
                "rect": pygame.Rect(self.four_steps_list[-1][new_step_index]["rect"].x, y_position - 150, 116, 36),
                "type": "step"}

            # set the index for new step
            self.quadruple_row_step_index = new_step_index

            # remove the row that goes off the screen
            self.four_steps_list.remove(self.four_steps_list[0])

        # add new three steps rows and delete those off the screen
        if self.three_steps_list[0][0]["rect"].y > 600:
            y_position = self.four_steps_list[-1][0]["rect"].y

            # generate new step index based on previous step index in quadruple row
            new_step_index = random.randint(*self.three_step_row_options[self.quadruple_row_step_index])

            # add three new clouds in a row
            self.three_steps_list.append(
                [{"rect": pygame.Rect(250, y_position - 150, 116, 36), "type": "cloud"},
                 {"rect": pygame.Rect(550, y_position - 150, 116, 36), "type": "cloud"},
                 {"rect": pygame.Rect(850, y_position - 150, 116, 36), "type": "cloud"}])

            # change one of the clouds to step
            self.three_steps_list[-1][new_step_index] = {
                "rect": pygame.Rect(self.three_steps_list[-1][new_step_index]["rect"].x, y_position - 150, 116, 36),
                "type": "step"}

            # set the index for new step
            self.triple_row_step_index = new_step_index

            # remove the row that goes off the screen
            self.three_steps_list.remove(self.three_steps_list[0])

        # move the steps
        if self.move_steps:
            for row in self.three_steps_list:
                for step in row:
                    step["rect"].y += self.steps_velocity

            for row in self.four_steps_list:
                for step in row:
                    step["rect"].y += self.steps_velocity

            # increase steps velocity and stop moving steps after reaching the cut-off value
            self.steps_velocity -= 1
            if self.steps_velocity == 2:
                self.move_steps = False
                self.steps_velocity = 17

    def draw_time_bar(self, audio_enabled):
        pygame.draw.rect(self.screen, "gray", (0, SCREEN_HEIGHT - 40, SCREEN_WIDTH, 40))
        pygame.draw.rect(self.screen, "green", (0, SCREEN_HEIGHT - 40, SCREEN_WIDTH - self.time_elapsed, 40))

        # increase elapsed time
        self.time_elapsed += 1 + self.score / 10

        # time bar cannot be wider that screen
        if self.time_elapsed < 0:
            self.time_elapsed = 0

        # game over if time bar ends
        if self.time_elapsed > SCREEN_WIDTH:
            self.game_over = True
            play_sound(GAME_OVER_SOUND, audio_enabled)
            stop_sound(SKY_HOP_SOUND, audio_enabled)

    def set_starting_values(self):
        self.x = SCREEN_WIDTH / 2 - self.pou_width / 2
        self.y = 440
        self.score = 0
        self.time_elapsed = 0
        self.game_over = False

        self.move_steps = False
        self.steps_velocity = 17

        self.move_pou = False
        self.pou_velocity = -10
        self.direction = "R"

        # initial steps indexes
        self.triple_row_step_index = 1
        self.quadruple_row_step_index = 1

        # create list of four steps rows
        self.four_steps_list = [
            [{"rect": pygame.Rect(100, 350, 116, 36), "type": "cloud"},
             {"rect": pygame.Rect(400, 350, 116, 36), "type": "cloud"},
             {"rect": pygame.Rect(700, 350, 116, 36), "type": "step"},
             {"rect": pygame.Rect(1000, 350, 116, 36), "type": "cloud"}],
            [{"rect": pygame.Rect(100, 50, 116, 36), "type": "cloud"},
             {"rect": pygame.Rect(400, 50, 116, 36), "type": "step"},
             {"rect": pygame.Rect(700, 50, 116, 36), "type": "cloud"},
             {"rect": pygame.Rect(1000, 50, 116, 36), "type": "cloud"}]

        ]
        # create list of three steps rows
        self.three_steps_list = [
            [{"rect": pygame.Rect(250, 500, 116, 36), "type": "cloud"},
             {"rect": pygame.Rect(550, 500, 116, 36), "type": "step"},
             {"rect": pygame.Rect(850, 500, 116, 36), "type": "cloud"}],
            [{"rect": pygame.Rect(250, 200, 116, 36), "type": "cloud"},
             {"rect": pygame.Rect(550, 200, 116, 36), "type": "step"},
             {"rect": pygame.Rect(850, 200, 116, 36), "type": "cloud"}]
        ]
