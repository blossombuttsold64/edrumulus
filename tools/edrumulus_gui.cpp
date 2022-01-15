
// Edrumulus simple terminal GUI
// compile with: gcc edrumulus_gui.cpp -o gui -lncurses -ljack -lstdc++

#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <algorithm>
#include <vector>
#include <string>
#include <curses.h>
#include <jack/jack.h>
#include <jack/midiport.h>

// tables
const int   max_num_pads = 8;
const int   number_cmd   = 12;
std::vector<std::string> pad_types   { "PD120", "PD80R", "PD8", "FD8", "VH12", "VH12CTRL", "KD7", "TP80", "CY6", "CY8", "DIABOLO12", "CY5", "HD1TOM", "PD6", "KD8", "PDX8", "KD120", "PD5" };
std::vector<std::string> curve_types { "LINEAR", "EXP1", "EXP2", "LOG1", "LOG2" };
std::vector<std::string> cmd_names   { "type", "thresh", "sens", "pos thres", "pos sens", "rim thres", "curve", "spike", "rim/pos", "note", "note rim", "cross" };
std::vector<int>         cmd_val     {    102,      103,    104,         105,        106,         107,     109,     110,       111,    112,        113,     114 };
std::vector<int>         cmd_val_rng {     17,       31,     31,          31,         31,          31,       4,       4,         3,    127,        127,      31 };
std::vector<int> param_set ( number_cmd, 0 );
jack_port_t* input_port;
jack_port_t* output_port;
int          sel_pad       = 0;
int          sel_cmd       = 0;
int          midi_send_cmd = -1; // invalidate per default
int          midi_send_val;

// parse command parameter
std::string parse_cmd_param ( int cmd )
{
  return cmd == 0 ? pad_types[param_set[cmd]] : cmd == 6 ? curve_types[param_set[cmd]] : std::to_string ( param_set[cmd] );
}

// jack audio callback function
int process ( jack_nframes_t nframes, void *arg )
{
  void*        in_midi       = jack_port_get_buffer ( input_port,  nframes );
  void*        out_midi      = jack_port_get_buffer ( output_port, nframes );
  jack_nframes_t event_count = jack_midi_get_event_count ( in_midi );

  for ( jack_nframes_t j = 0; j < event_count; j++ )
  {
    jack_midi_event_t in_event;
    jack_midi_event_get ( &in_event, in_midi, j );

    if ( in_event.size == 3 )
    {
      // if MIDI note-off and command is found, apply received parameter
      auto it = std::find ( cmd_val.begin(), cmd_val.end(), in_event.buffer[1] );
      if ( it != cmd_val.end() && ( in_event.buffer[0] & 0xF0 ) == 0x80 )
      {
        int cur_cmd = std::distance ( cmd_val.begin(), it );
        param_set[cur_cmd] = std::max ( 0, std::min ( cmd_val_rng[cur_cmd], (int) in_event.buffer[2] ) );

// TEST update current received parameter in the GUI
move ( 9, 10 ); deleteln();
mvprintw ( 9, 10, "Parameter value:  %s", parse_cmd_param ( sel_cmd ).c_str() );
refresh();

      }
    }
  }

  jack_midi_clear_buffer ( out_midi );
  if ( midi_send_cmd >= 0 )
  {
    jack_midi_data_t* midi_out_buffer = jack_midi_event_reserve ( out_midi, 0, 3 );
    midi_out_buffer[0] = 185; // control change MIDI message on channel 10
    midi_out_buffer[1] = midi_send_cmd;
    midi_out_buffer[2] = midi_send_val;
    midi_send_cmd      = -1; // invalidate current command to prepare for next command
  }

  return 0;
}

// main function
int main()
{
  int ch;

  // initialize jack audio for MIDI
  jack_client_t* client = jack_client_open   ( "EdrumulusGUI", JackNullOption, nullptr );
  input_port            = jack_port_register ( client, "MIDI_in",  JACK_DEFAULT_MIDI_TYPE, JackPortIsInput,  0 );
  output_port           = jack_port_register ( client, "MIDI_out", JACK_DEFAULT_MIDI_TYPE, JackPortIsOutput, 0 );
  jack_set_process_callback ( client, process, nullptr );
  jack_activate             ( client );
  jack_connect              ( client, "ttymidi:MIDI_in",       "EdrumulusGUI:MIDI_in" );
  jack_connect              ( client, "EdrumulusGUI:MIDI_out", "ttymidi:MIDI_out" );

  // initialize GUI
  WINDOW* mainwin = initscr();
  noecho();                  // turn off key echoing
  keypad  ( mainwin, true ); // enable the keypad for non-char keys
  nodelay ( mainwin, true ); // we want a non-blocking getch()

  // show usage
  mvaddstr ( 5, 10, "Press a key; q:quit; s,S:sel pad; c,C:sel command; up,down: change parameter" );
  refresh();

  // loop until user presses q
  while ( ( ch = getch() ) != 'q' )
  {
    if ( ch != -1 )
    {
      // delete the old response lines
      move ( 9, 10 ); deleteln();
      move ( 8, 10 ); deleteln();
      move ( 7, 10 ); deleteln();

      if ( ch == 's' || ch == 'S' ) // change selected pad
      {
        ch == 's' ? sel_pad++ : sel_pad--;
        sel_pad = std::max ( 0, std::min ( max_num_pads - 1, sel_pad ) );
        midi_send_val = sel_pad;
        midi_send_cmd = 108;
      }
      else if ( ch == 'c' || ch == 'C' ) // change selected command
      {
        ch == 'c' ? sel_cmd++ : sel_cmd--;
        sel_cmd = std::max ( 0, std::min ( number_cmd - 1, sel_cmd ) );
      }
      else if ( ch == 258 || ch == 259 ) // change parameter value with up/down keys
      {
        ch == 259 ? param_set[sel_cmd]++ : param_set[sel_cmd]--;
        param_set[sel_cmd] = std::max ( 0, std::min ( cmd_val_rng[sel_cmd], param_set[sel_cmd] ) );
        midi_send_val = param_set[sel_cmd];
        midi_send_cmd = cmd_val[sel_cmd];
      }

      mvprintw ( 9, 10, "Parameter value:  %s", parse_cmd_param ( sel_cmd ).c_str() );
      mvprintw ( 8, 10, "Selected pad:     %d", sel_pad );
      mvprintw ( 7, 10, "Selected command: %s", cmd_names[sel_cmd].c_str() );
      refresh();
    }

    usleep ( 100000 );
  }

  // clean up and exit
  delwin ( mainwin );
  endwin();
  refresh();
  jack_deactivate      ( client );
  jack_port_unregister ( client, input_port );
  jack_port_unregister ( client, output_port );
  jack_client_close    ( client );

  return EXIT_SUCCESS;
}

