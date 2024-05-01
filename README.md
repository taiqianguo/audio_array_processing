# audio_array_processing
An angle detection FPGA implementation with two audio reciever based on AoA(angle of arrival) algorithm

The project use matlab to approximate and simualate the propagation of vioce signal in free space and using two reciver to accept signal for futher processigng.
And to get processing result , the princple is illustrated below, the main part is using cross correlation to detect the delay of signal between two reciever.
 <img width="400" alt="https://github.com/taiqianguo/audio_array_processing/assets/58079218/6f676eed-b1fa-4372-94f2-407abddbe911">

 The matlab simulation result shows below:
<img width="1130" alt="image" src="https://github.com/taiqianguo/audio_array_processing/assets/58079218/1f56cba0-76af-4e53-b3f4-3427685b16b9">

Then we use FPGA to validate the digital design of this signal.
FPGA design sample 1024 two channel's deepth and use cyclic correlation to determine the delay, and the delay is euqal to abs(512-delay_of_max_correlation_value).
Then multiply the Fs to culculate real delay.
After get delay , we simply use a look up table to culculate arcsin function to generate the arrival angle.
the simulation result shows below: after detect the max correlation point the max_delay stop to update until it find a larger value.
<img width="1121" alt="image" src="https://github.com/taiqianguo/audio_array_processing/assets/58079218/cadbde5a-d5a5-45db-a17e-f230730b0a62">

Saidly, this first version do not provide parallel acceleration of the culculation , and could theoritically use more statistical method like differential point detctions.
