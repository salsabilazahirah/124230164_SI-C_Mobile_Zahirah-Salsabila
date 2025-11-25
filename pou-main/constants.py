import pygame

pygame.init()

SCREEN_WIDTH = 1200
SCREEN_HEIGHT = 600
FOOD_IMAGE_HEIGHT = 50
FOOD_IMAGE_WIDTH = 50
CHARACTER_WIDTH = 100
CHARACTER_HEIGHT = 100
SMALL_FONT = pygame.font.Font("default_font.ttf", 30)
MEDIUM_FONT = pygame.font.Font("default_font.ttf", 40)
BIG_FONT = pygame.font.Font("default_font.ttf", 50)
EAT_SOUND = pygame.mixer.Sound("audio/eat.wav")
GAME_OVER_SOUND = pygame.mixer.Sound("audio/game_over.wav")
FOOD_DROP_SOUND = pygame.mixer.Sound("audio/food_drop_song.mp3")
JET_POU_SOUND = pygame.mixer.Sound("audio/jet_pou_sound.mp3")
JETPACK_SOUND = pygame.mixer.Sound("audio/jetpack_sound.mp3")
SKY_HOP_SOUND = pygame.mixer.Sound("audio/sky_hop_song.mp3")
JUMP_SOUND = pygame.mixer.Sound("audio/jump.mp3")
