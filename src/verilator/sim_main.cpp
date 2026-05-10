#include <iostream>
#include <SDL2/SDL.h>
#include "Vcomputer.h"
#include "verilated.h"
#include "font8x8_basic.h"

// Terminal settings
const int TERM_WIDTH = 80;
const int TERM_HEIGHT = 24;
const int CHAR_WIDTH = 8;
const int CHAR_HEIGHT = 8;
const int SCREEN_WIDTH = TERM_WIDTH * CHAR_WIDTH;
const int SCREEN_HEIGHT = TERM_HEIGHT * CHAR_HEIGHT;

char terminal[TERM_HEIGHT][TERM_WIDTH];
int cursor_x = 0;
int cursor_y = 0;

void scroll() {
    for (int y = 1; y < TERM_HEIGHT; y++) {
        for (int x = 0; x < TERM_WIDTH; x++) {
            terminal[y-1][x] = terminal[y][x];
        }
    }
    for (int x = 0; x < TERM_WIDTH; x++) terminal[TERM_HEIGHT-1][x] = ' ';
    cursor_y = TERM_HEIGHT - 1;
}

void print_char(char c) {
    if (c == '\n') {
        cursor_x = 0;
        cursor_y++;
    } else if (c == '\r') {
        cursor_x = 0;
    } else if (c == '\b') {
        if (cursor_x > 0) cursor_x--;
    } else {
        if (cursor_x >= TERM_WIDTH) {
            cursor_x = 0;
            cursor_y++;
        }
        if (cursor_y >= TERM_HEIGHT) scroll();
        terminal[cursor_y][cursor_x] = c;
        cursor_x++;
    }
    if (cursor_y >= TERM_HEIGHT) scroll();
}

void render_text(SDL_Renderer* renderer) {
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255); // Black bg
    SDL_RenderClear(renderer);
    SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255); // Green fg

    for (int y = 0; y < TERM_HEIGHT; y++) {
        for (int x = 0; x < TERM_WIDTH; x++) {
            char c = terminal[y][x];
            if (c < 0 || c > 127) c = ' ';
            char* bitmap = font8x8_basic[(int)c];
            
            for (int r = 0; r < 8; r++) {
                for (int c_bit = 0; c_bit < 8; c_bit++) {
                    if (bitmap[r] & (1 << c_bit)) {
                        SDL_RenderDrawPoint(renderer, x * 8 + c_bit, y * 8 + r);
                    }
                }
            }
        }
    }
    
    // Draw cursor
    SDL_Rect cursor = {cursor_x * 8, cursor_y * 8 + 6, 8, 2};
    SDL_RenderFillRect(renderer, &cursor);
    
    SDL_RenderPresent(renderer);
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vcomputer* top = new Vcomputer;
    
    for (int y = 0; y < TERM_HEIGHT; y++)
        for (int x = 0; x < TERM_WIDTH; x++)
            terminal[y][x] = ' ';

    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << "SDL_Init Error: " << SDL_GetError() << std::endl;
        return 1;
    }
    
    SDL_Window* window = SDL_CreateWindow("MIPS32 Terminal", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH*2, SCREEN_HEIGHT*2, SDL_WINDOW_SHOWN);
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    SDL_RenderSetScale(renderer, 2.0, 2.0);
    
    SDL_StartTextInput();
    
    top->reset = 1;
    top->clk = 0;
    top->rx_valid = 0;
    top->rx_data = 0;
    
    for (int i=0; i<10; i++) {
        top->clk = !top->clk; top->eval();
    }
    top->reset = 0;
    
    bool quit = false;
    SDL_Event e;
    
    int cycles_per_frame = 50000; 

    while (!quit) {
        for (int i = 0; i < cycles_per_frame; i++) {
            top->clk = 1; top->eval();
            top->clk = 0; top->eval();
            
            if (top->tx_write) {
                print_char((char)top->tx_data);
            }
            if (top->rx_ack) {
                top->rx_valid = 0;
            }
        }
        
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) {
                quit = true;
            } else if (e.type == SDL_TEXTINPUT && !top->rx_valid) {
                top->rx_data = e.text.text[0];
                top->rx_valid = 1;
            } else if (e.type == SDL_KEYDOWN && !top->rx_valid) {
                if (e.key.keysym.sym == SDLK_RETURN) {
                    top->rx_data = '\n';
                    top->rx_valid = 1;
                } else if (e.key.keysym.sym == SDLK_BACKSPACE) {
                    top->rx_data = '\b';
                    top->rx_valid = 1;
                }
            }
        }
        
        render_text(renderer);
    }
    
    SDL_StopTextInput();
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    
    top->final();
    delete top;
    return 0;
}
