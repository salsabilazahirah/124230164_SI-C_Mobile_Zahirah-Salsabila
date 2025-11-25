from constants import BIG_FONT


class Button:
    TEXT_COLOR = "black"
    HIGHLIGHTED_TEXT_COLOR = "red"

    def __init__(self, y, screen, text):
        self.y = y
        self.screen = screen
        self.text = text
        self.width = self.screen.get_rect()
        self.selected = False

    def draw(self):
        # set the text color
        if self.selected:
            color = self.HIGHLIGHTED_TEXT_COLOR
        else:
            color = self.TEXT_COLOR

        # render the text
        text_rendered = BIG_FONT.render(self.text, True, color)

        # calculate the centered x position
        text_width = text_rendered.get_width()
        center_x = self.screen.get_width() / 2 - text_width / 2

        # draw the text at the centered position
        self.screen.blit(text_rendered, (center_x, self.y))

    def set_selected(self, selected):
        self.selected = selected
