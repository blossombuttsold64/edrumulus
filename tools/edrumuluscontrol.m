%*******************************************************************************
% Copyright (c) 2020-2021
% Author(s): Volker Fischer
%*******************************************************************************
% This program is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation; either version 2 of the License, or (at your option) any later
% version.
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
% details.
% You should have received a copy of the GNU General Public License along with
% this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
%*******************************************************************************

function edrumuluscontrol

global GUI;

close all;
pkg load audio

figure_handle = figure;
slider_width  = 0.12;
slider_hight  = 0.7;
value_hight   = 0.2;

% MIDI device selection combo box
GUI.midi_dev_list = uicontrol(figure_handle, ...
  'style',    'listbox', ...
  'units',    'normalized', ...
  'position', [0, 0.8, 0.4, 0.2], ...
  'callback', @midi_sel_callback);

midi_devices = mididevinfo;
for i = 1:length(midi_devices.output)
  set(GUI.midi_dev_list, 'string', midi_devices.output{i}.Name);
end
GUI.midi_dev = [];

% default settings button
GUI.set_but = uicontrol(figure_handle, ...
  'style',    'pushbutton', ... 
  'string',   'Default Settings', ...
  'units',    'normalized', ...
  'position', [0.7, 0.9, 0.3, 0.1], ...
  'callback', @button_callback);

% spike cancellation checkbox
GUI.spike_chbx = uicontrol(figure_handle, ...
  'style',    'checkbox', ...
  'value',    1, ... % is on per default on the ESP32
  'string',   'Spike Cancellation', ...
  'units',    'normalized', ...
  'position', [0.7, 0.75, 0.3, 0.1], ...
  'callback', @checkbox_callback);

% settings panel
GUI.set_panel = uipanel(figure_handle, ...
  'Title',    'Edrumulus settings', ...
  'Position', [0 0 1 0.6]);

% first slider control with text
uicontrol(GUI.set_panel, ...
  'style',    'text', ...
  'string',   '1:Pad Type', ...
  'units',    'normalized', ...
  'position', [0, slider_hight + value_hight, slider_width, 0.1]);

GUI.val1 = uicontrol(GUI.set_panel, ...
  'style',    'edit', ...
  'units',    'normalized', ...
  'position', [0, slider_hight, slider_width, 0.2], ...
  'Enable',   'off');

GUI.slider1 = uicontrol(GUI.set_panel, ...
  'style',      'slider', ...
  'min',        0, ...
  'max',        2, ...
  'SliderStep', [1 / 2, 1 / 2], ...
  'units',      'normalized', ...
  'position',   [0, 0, slider_width, slider_hight], ...
  'callback',   @slider_callback);

% second slider control with text
uicontrol(GUI.set_panel, ...
  'style',    'text', ...
  'string',   '2:Threshold', ...
  'units',    'normalized', ...
  'position', [slider_width, slider_hight + value_hight, slider_width, 0.1]);

GUI.val2 = uicontrol(GUI.set_panel, ...
  'style',    'edit', ...
  'units',    'normalized', ...
  'position', [slider_width, slider_hight, slider_width, 0.2], ...
  'Enable',   'off');

GUI.slider2 = uicontrol(GUI.set_panel, ...
  'style',      'slider', ...
  'units',      'normalized', ...
  'min',        0, ...
  'max',        31, ...
  'SliderStep', [1 / 31, 1 / 31], ...
  'position',   [slider_width, 0, slider_width, slider_hight], ...
  'callback',   @slider_callback);

% third slider control with text
uicontrol(GUI.set_panel, ...
  'style',    'text', ...
  'string',   '3:Sensitivity', ...
  'units',    'normalized', ...
  'position', [2 * slider_width, slider_hight + value_hight, slider_width, 0.1]);

GUI.val3 = uicontrol(GUI.set_panel, ...
  'style',    'edit', ...
  'units',    'normalized', ...
  'position', [2 * slider_width, slider_hight, slider_width, 0.2], ...
  'Enable',   'off');

GUI.slider3 = uicontrol(GUI.set_panel, ...
  'style',      'slider', ...
  'min',        0, ...
  'max',        31, ...
  'SliderStep', [1 / 31, 1 / 31], ...
  'units',      'normalized', ...
  'position',   [2 * slider_width, 0, slider_width, slider_hight], ...
  'callback',   @slider_callback);

% fourth slider control with text
uicontrol(GUI.set_panel, ...
  'style',    'text', ...
  'string',   '4:Pos Threshold', ...
  'units',    'normalized', ...
  'position', [3 * slider_width, slider_hight + value_hight, slider_width, 0.1]);

GUI.val4 = uicontrol(GUI.set_panel, ...
  'style',    'edit', ...
  'units',    'normalized', ...
  'position', [3 * slider_width, slider_hight, slider_width, 0.2], ...
  'Enable',   'off');

GUI.slider4 = uicontrol(GUI.set_panel, ...
  'style',      'slider', ...
  'units',      'normalized', ...
  'min',        0, ...
  'max',        31, ...
  'SliderStep', [1 / 31, 1 / 31], ...
  'position',   [3 * slider_width, 0, slider_width, slider_hight], ...
  'callback',   @slider_callback);

% fifth slider control with text
uicontrol(GUI.set_panel, ...
  'style',    'text', ...
  'string',   '5:Pos Sensitivity', ...
  'units',    'normalized', ...
  'position', [4 * slider_width, slider_hight + value_hight, slider_width, 0.1]);

GUI.val5 = uicontrol(GUI.set_panel, ...
  'style',    'edit', ...
  'units',    'normalized', ...
  'position', [4 * slider_width, slider_hight, slider_width, 0.2], ...
  'Enable',   'off');

GUI.slider5 = uicontrol(GUI.set_panel, ...
  'style',      'slider', ...
  'units',      'normalized', ...
  'min',        0, ...
  'max',        31, ...
  'SliderStep', [1 / 31, 1 / 31], ...
  'position',   [4 * slider_width, 0, slider_width, slider_hight], ...
  'callback',   @slider_callback);

% sixth slider control with text
uicontrol(GUI.set_panel, ...
  'style',    'text', ...
  'string',   '6:Rim Shot Threshold', ...
  'units',    'normalized', ...
  'position', [5 * slider_width, slider_hight + value_hight, slider_width, 0.1]);

GUI.val6 = uicontrol(GUI.set_panel, ...
  'style',    'edit', ...
  'units',    'normalized', ...
  'position', [5 * slider_width, slider_hight, slider_width, 0.2], ...
  'Enable',   'off');

GUI.slider6 = uicontrol(GUI.set_panel, ...
  'style',      'slider', ...
  'units',      'normalized', ...
  'min',        0, ...
  'max',        31, ...
  'SliderStep', [1 / 31, 1 / 31], ...
  'position',   [5 * slider_width, 0, slider_width, slider_hight], ...
  'callback',   @slider_callback);

% seventh slider control with text
uicontrol(GUI.set_panel, ...
  'style',    'text', ...
  'string',   '7:MIDI Curve', ...
  'units',    'normalized', ...
  'position', [6 * slider_width, slider_hight + value_hight, slider_width, 0.1]);

GUI.val7 = uicontrol(GUI.set_panel, ...
  'style',    'edit', ...
  'units',    'normalized', ...
  'position', [6 * slider_width, slider_hight, slider_width, 0.2], ...
  'Enable',   'off');

GUI.slider7 = uicontrol(GUI.set_panel, ...
  'style',      'slider', ...
  'units',      'normalized', ...
  'min',        0, ...
  'max',        4, ...
  'SliderStep', [1 / 4, 1 / 4], ...
  'position',   [6 * slider_width, 0, slider_width, slider_hight], ...
  'callback',   @slider_callback);

% eigth slider control with text
uicontrol(GUI.set_panel, ...
  'style',    'text', ...
  'string',   '8:Pad Select', ...
  'units',    'normalized', ...
  'position', [7 * slider_width, slider_hight + value_hight, slider_width, 0.1]);

GUI.val8 = uicontrol(GUI.set_panel, ...
  'style',    'edit', ...
  'units',    'normalized', ...
  'position', [7 * slider_width, slider_hight, slider_width, 0.2], ...
  'Enable',   'off');

GUI.slider8 = uicontrol(GUI.set_panel, ...
  'style',      'slider', ...
  'units',      'normalized', ...
  'min',        0, ...
  'max',        11, ...
  'SliderStep', [1 / 11, 1 / 11], ...
  'position',   [7 * slider_width, 0, slider_width, slider_hight], ...
  'callback',   @slider_callback);

reset_sliders;

end


function midi_sel_callback(hObject)

global GUI;
GUI.midi_dev = mididevice("output", get(hObject, 'string'));

end


function reset_sliders

global GUI;
set(GUI.slider2, 'value', 0); set(GUI.val2, 'string', 'Not Set');
set(GUI.slider3, 'value', 0); set(GUI.val3, 'string', 'Not Set');
set(GUI.slider4, 'value', 0); set(GUI.val4, 'string', 'Not Set');
set(GUI.slider5, 'value', 0); set(GUI.val5, 'string', 'Not Set');
set(GUI.slider6, 'value', 0); set(GUI.val6, 'string', 'Not Set');
set(GUI.slider7, 'value', 0); set(GUI.val7, 'string', 'Not Set');

end


function slider_callback(hObject)

global GUI;

value = round(get(hObject, 'value'));

switch hObject
   case GUI.slider1
     switch value
       case 0
         set(GUI.val1, 'string', 'PD120');
       case 1
         set(GUI.val1, 'string', 'PD80R');
       case 2
         set(GUI.val1, 'string', 'PD8');
     end
     midisend(GUI.midi_dev, midimsg("controlchange", 10, 102, value));
     reset_sliders; % if a pad type is changed, all parameters are reset in the ESP32

   case GUI.slider2
     set(GUI.val2, 'string', num2str(value));
     midisend(GUI.midi_dev, midimsg("controlchange", 10, 103, value));

   case GUI.slider3
     set(GUI.val3, 'string', num2str(value));
     midisend(GUI.midi_dev, midimsg("controlchange", 10, 104, value));

   case GUI.slider4
     set(GUI.val4, 'string', num2str(value));
     midisend(GUI.midi_dev, midimsg("controlchange", 10, 105, value));

   case GUI.slider5
     set(GUI.val5, 'string', num2str(value));
     midisend(GUI.midi_dev, midimsg("controlchange", 10, 106, value));

   case GUI.slider6
     set(GUI.val6, 'string', num2str(value));
     midisend(GUI.midi_dev, midimsg("controlchange", 10, 107, value));

 case GUI.slider7
     switch value
       case 0
         set(GUI.val7, 'string', 'LINEAR');
       case 1
         set(GUI.val7, 'string', 'EXP1');
       case 2
         set(GUI.val7, 'string', 'EXP2');
       case 3
         set(GUI.val7, 'string', 'LOG1');
       case 4
         set(GUI.val7, 'string', 'LOG2');
     end
     midisend(GUI.midi_dev, midimsg("controlchange", 10, 109, value));

   case GUI.slider8
     set(GUI.val8, 'string', num2str(value));
     midisend(GUI.midi_dev, midimsg("controlchange", 10, 108, value));
     reset_sliders; % on a pad change we do not know the current parameters
end

end


function button_callback(hObject)

global GUI;

% snare
midisend(GUI.midi_dev, midimsg("controlchange", 10, 108, 0)); % pad 0
midisend(GUI.midi_dev, midimsg("controlchange", 10, 102, 2)); % PD8
midisend(GUI.midi_dev, midimsg("controlchange", 10, 103, 0)); % threshold
midisend(GUI.midi_dev, midimsg("controlchange", 10, 104, 8)); % sensitivity
midisend(GUI.midi_dev, midimsg("controlchange", 10, 107, 16)); % rim shot threshold
midisend(GUI.midi_dev, midimsg("controlchange", 10, 111, 3)); % both, rim shot and positional sensing

% kick
midisend(GUI.midi_dev, midimsg("controlchange", 10, 108, 1)); % pad 1
midisend(GUI.midi_dev, midimsg("controlchange", 10, 102, 0)); % PD120
midisend(GUI.midi_dev, midimsg("controlchange", 10, 103, 9)); % threshold
midisend(GUI.midi_dev, midimsg("controlchange", 10, 104, 9)); % sensitivity

% hi-hat
midisend(GUI.midi_dev, midimsg("controlchange", 10, 108, 2)); % pad 2
midisend(GUI.midi_dev, midimsg("controlchange", 10, 102, 2)); % PD8
midisend(GUI.midi_dev, midimsg("controlchange", 10, 103, 0)); % threshold
midisend(GUI.midi_dev, midimsg("controlchange", 10, 104, 8)); % sensitivity
midisend(GUI.midi_dev, midimsg("controlchange", 10, 111, 1)); % enable rim shot

% crash
midisend(GUI.midi_dev, midimsg("controlchange", 10, 108, 4)); % pad 4
midisend(GUI.midi_dev, midimsg("controlchange", 10, 102, 2)); % PD8
midisend(GUI.midi_dev, midimsg("controlchange", 10, 103, 11)); % threshold
midisend(GUI.midi_dev, midimsg("controlchange", 10, 104, 21)); % sensitivity
midisend(GUI.midi_dev, midimsg("controlchange", 10, 111, 1)); % enable rim shot

% tom 1
midisend(GUI.midi_dev, midimsg("controlchange", 10, 108, 5)); % pad 5
midisend(GUI.midi_dev, midimsg("controlchange", 10, 102, 1)); % PD80R
midisend(GUI.midi_dev, midimsg("controlchange", 10, 103, 9)); % threshold
midisend(GUI.midi_dev, midimsg("controlchange", 10, 104, 0)); % sensitivity

% ride
midisend(GUI.midi_dev, midimsg("controlchange", 10, 108, 6)); % pad 6
midisend(GUI.midi_dev, midimsg("controlchange", 10, 102, 2)); % PD8
midisend(GUI.midi_dev, midimsg("controlchange", 10, 103, 18)); % threshold
midisend(GUI.midi_dev, midimsg("controlchange", 10, 104, 21)); % sensitivity
midisend(GUI.midi_dev, midimsg("controlchange", 10, 111, 1)); % enable rim shot

% tom 2
midisend(GUI.midi_dev, midimsg("controlchange", 10, 108, 7)); % pad 7
midisend(GUI.midi_dev, midimsg("controlchange", 10, 102, 1)); % PD80R
midisend(GUI.midi_dev, midimsg("controlchange", 10, 103, 18)); % threshold
midisend(GUI.midi_dev, midimsg("controlchange", 10, 104, 0)); % sensitivity

% cleanup GUI
midisend(GUI.midi_dev, midimsg("controlchange", 10, 108, 0)); % pad 0
reset_sliders;

end


function checkbox_callback(hObject)

global GUI;

% spike cancellation checkbox
midisend(GUI.midi_dev, midimsg("controlchange", 10, 110, get(hObject, 'value')));

end


