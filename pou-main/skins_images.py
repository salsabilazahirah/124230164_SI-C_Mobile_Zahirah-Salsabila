import pygame
from constants import CHARACTER_WIDTH, CHARACTER_HEIGHT

DEFAULT_IMAGE = pygame.image.load("skins/default.png")
COAT_IMAGE = pygame.image.load("skins/coat.png")
PANDA_IMAGE = pygame.image.load("skins/panda.png")
POLO_IMAGE = pygame.image.load("skins/polo.png")
PUMPKIN_IMAGE = pygame.image.load("skins/pumpkin.png")
T_SHIRT_IMAGE = pygame.image.load("skins/t-shirt.png")

default_img = pygame.transform.scale(DEFAULT_IMAGE, (CHARACTER_WIDTH, CHARACTER_HEIGHT))
coat_img = pygame.transform.scale(COAT_IMAGE, (CHARACTER_WIDTH, CHARACTER_HEIGHT))
panda_img = pygame.transform.scale(PANDA_IMAGE, (CHARACTER_WIDTH, CHARACTER_HEIGHT))
polo_img = pygame.transform.scale(POLO_IMAGE, (CHARACTER_WIDTH, CHARACTER_HEIGHT))
pumpkin_img = pygame.transform.scale(PUMPKIN_IMAGE, (CHARACTER_WIDTH, CHARACTER_HEIGHT))
t_shirt_img = pygame.transform.scale(T_SHIRT_IMAGE, (CHARACTER_WIDTH, CHARACTER_HEIGHT))
