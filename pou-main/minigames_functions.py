from constants import MEDIUM_FONT, SCREEN_WIDTH, SMALL_FONT


def draw_game_over_menu(screen, score):
    final_score_text = MEDIUM_FONT.render(f"Final score: {score}", True, "black")
    screen.blit(final_score_text, (SCREEN_WIDTH / 2 - final_score_text.get_width() / 2, 150))
    play_again_text = MEDIUM_FONT.render("Press Enter to play again", True, "black")
    screen.blit(play_again_text, (SCREEN_WIDTH / 2 - play_again_text.get_width() / 2, 250))
    move_back_text = MEDIUM_FONT.render("Press Escape to open main menu", True, "black")
    screen.blit(move_back_text, (SCREEN_WIDTH / 2 - move_back_text.get_width() / 2, 350))


def draw_score(screen, score):
    score_text = SMALL_FONT.render(f"Score: {score}", True, "black")
    screen.blit(score_text, (50, 50))


def play_sound(sound, audio_enabled):
    if audio_enabled:
        sound.play()


def stop_sound(sound, audio_enabled):
    if audio_enabled:
        sound.stop()