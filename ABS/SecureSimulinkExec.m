% Calling simulink model and security


clc
clear all


% TASK 1

% Calculate Gaussian models for heart rate and respiratory rate
numSamples = 100;

% User Profiles for LCW
user1_heartRate_lcw = [80, 14];
user1_respRate_lcw = [16, 6];

user2_heartRate_lcw = [65, 15];
user2_respRate_lcw = [13, 4];

user3_heartRate_lcw = [61, 14];
user3_respRate_lcw = [17, 8];

% Calculate Average Heart Rate for LCW
heartRateMean_lcw = (user1_heartRate_lcw(1) + user2_heartRate_lcw(1) + user3_heartRate_lcw(1)) / 3;

% Calculate Average Respiratory Rate for LCW
respRateMean_lcw = (user1_respRate_lcw(1) + user2_respRate_lcw(1) + user3_respRate_lcw(1)) / 3;

% Calculate Standard Deviation of Heart Rate (Population Std Dev) for LCW
heartRateStdDev_lcw = sqrt((user1_heartRate_lcw(2)^2 + user2_heartRate_lcw(2)^2 + user3_heartRate_lcw(2)^2) / 3);

% Calculate Standard Deviation of Respiratory Rate (Population Std Dev) for LCW
respRateStdDev_lcw = sqrt((user1_respRate_lcw(2)^2 + user2_respRate_lcw(2)^2 + user3_respRate_lcw(2)^2) / 3);

% Display the calculated values for LCW
disp(['Average Heart Rate for LCW: ', num2str(heartRateMean_lcw)]);
disp(['Heart Rate Standard Deviation for LCW: ', num2str(heartRateStdDev_lcw)]);
disp(['Average Respiratory Rate for LCW: ', num2str(respRateMean_lcw)]);
disp(['Respiratory Rate Standard Deviation for LCW: ', num2str(respRateStdDev_lcw)]);

% Generate random data points for heart rate following a Gaussian distribution
heartRateData_lcw = normrnd(heartRateMean_lcw, heartRateStdDev_lcw, 1, numSamples);

% Generate random data points for respiratory rate following a Gaussian distribution
respRateData_lcw = normrnd(respRateMean_lcw, respRateStdDev_lcw, 1, numSamples);





% User Profiles for HCW
user1_heartRate_hcw = [95, 26];
user1_respRate_hcw = [21, 14];

user2_heartRate_hcw = [71, 21];
user2_respRate_hcw = [14, 5];

user3_heartRate_hcw = [92, 23];
user3_respRate_hcw = [26, 16];

% Calculate Average Heart Rate for HCW
heartRateMean_hcw = (user1_heartRate_hcw(1) + user2_heartRate_hcw(1) + user3_heartRate_hcw(1)) / 3;

% Calculate Average Respiratory Rate for HCW
respRateMean_hcw = (user1_respRate_hcw(1) + user2_respRate_hcw(1) + user3_respRate_hcw(1)) / 3;

% Calculate Standard Deviation of Heart Rate (Population Std Dev) for HCW
heartRateStdDev_hcw = sqrt((user1_heartRate_hcw(2)^2 + user2_heartRate_hcw(2)^2 + user3_heartRate_hcw(2)^2) / 3);

% Calculate Standard Deviation of Respiratory Rate (Population Std Dev) for HCW
respRateStdDev_hcw = sqrt((user1_respRate_hcw(2)^2 + user2_respRate_hcw(2)^2 + user3_respRate_hcw(2)^2) / 3);

% Display the calculated values for HCW
disp(['Average Heart Rate for HCW: ', num2str(heartRateMean_hcw)]);
disp(['Heart Rate Standard Deviation for HCW: ', num2str(heartRateStdDev_hcw)]);
disp(['Average Respiratory Rate for HCW: ', num2str(respRateMean_hcw)]);
disp(['Respiratory Rate Standard Deviation for HCW: ', num2str(respRateStdDev_hcw)]);

% Generate random data points for heart rate following a Gaussian distribution
heartRateData_hcw = normrnd(heartRateMean_hcw, heartRateStdDev_hcw, 1, numSamples);

% Generate random data points for respiratory rate following a Gaussian distribution
respRateData_hcw = normrnd(respRateMean_hcw, respRateStdDev_hcw, 1, numSamples);




%  Creating Reaction Time array to store for 100 samples
Tr_LCW = zeros(numSamples, 1);
Tr_HCW = zeros(numSamples, 1);

for i = 1:numSamples
    % Generate a random index to select a value from heartRateData_lcw and respRateData_lcw
    randIndex = randi(length(heartRateData_lcw));
    
    % Assign a random value for heart rate and respiratory rate from the data in LCW
    hr_lcw = heartRateData_lcw(randIndex);
    rr_lcw = respRateData_lcw(randIndex);
    rq_lcw = hr_lcw/rr_lcw;
    Tr_LCW(i) = 0.01 * rq_lcw; 


    % Assign a random value for heart rate and respiratory rate from the data in HCW
    hr_hcw = heartRateData_hcw(randIndex);
    rr_hcw = respRateData_hcw(randIndex);
    rq_hcw = hr_hcw/rr_hcw;
    Tr_HCW(i) = 0.01 * rq_hcw;
end


% Initializing the required essential variables

decelLim_lcw = -200;
decelLim_hcw = -150;

minSwitchCount_lcw = inf;
minSwitchCount_hcw = inf;

bestGain_lcw = NaN;
bestGain_hcw = NaN;


% Calculating the best gain for both HCW and LCW 
for Gain = 10000:10000:100000
    [A,B,C,D,Kess, Kr, Ke, uD] = designControl(secureRand(),Gain);
    open_system('LaneMaintainSystem.slx')
    load_system('AdvisoryControl.slx');
    switchCount_lcw = 0;
    switchCount_hcw = 0;
    for InitSpeed = 20:40
        index = randi(length(Tr_LCW));
        curr_Tr_LCW = Tr_LCW(index);
        curr_Tr_HCW = Tr_HCW(index);
      
        set_param('LaneMaintainSystem/VehicleKinematics/Saturation','LowerLimit',num2str(decelLim_lcw))
        set_param('LaneMaintainSystem/VehicleKinematics/vx','InitialCondition',num2str(InitSpeed))

        simModel_lcw = sim('LaneMaintainSystem.slx');
        lastDistance_lcw = simModel_lcw.sx1.Data(end);
        for t = 1:length(simModel_lcw.sx1.Time)
            distance = simModel_lcw.sx1.Data(t);
            if distance > 0
                lastTime_lcw = simModel_lcw.sx1.Time(t);
                break; % Exit the loop as soon as distance exceeds 0
            end
        end



        % Importing the VehicleModelOnly.slx file to calculate the Action Time (Ta)
        % LCW
        set_param('AdvisoryControl/Step', 'Time', num2str(curr_Tr_LCW));
        set_param('AdvisoryControl/Step', 'After', num2str(decelLim_lcw*1.1));
        simModel_new_lcw = sim('AdvisoryControl.slx');
        Ta_lcw = simModel_new_lcw.sx1.Time(end);

        % disp("TA = " + Ta_lcw);
        % disp("TR =" + curr_Tr_LCW);

        h_stop_lcw = Ta_lcw + curr_Tr_LCW;
        disp("H stop for LCW is " + h_stop_lcw);

        if lastDistance_lcw >= 0
            if h_stop_lcw < lastTime_lcw
            switchCount_lcw = switchCount_lcw + 1;
            disp("Switch to Human")
            else
                disp("Do not switch")
            end
        else
            disp("Do not switch")
        end


        set_param('LaneMaintainSystem/VehicleKinematics/Saturation','LowerLimit',num2str(decelLim_hcw))
        set_param('LaneMaintainSystem/VehicleKinematics/vx','InitialCondition',num2str(InitSpeed))

        simModel_hcw = sim('LaneMaintainSystem.slx');
        lastDistance_hcw = simModel_hcw.sx1.Data(end);
        for t = 1:length(simModel_hcw.sx1.Time)
            distance = simModel_hcw.sx1.Data(t);
            if distance > 0
                lastTime_hcw = simModel_hcw.sx1.Time(t);
                break;
            end
        end


        % Importing the VehicleModelOnly.slx file to calculate the Action Time (Ta)
        % HCW
        set_param('AdvisoryControl/Step', 'Time', num2str(curr_Tr_HCW));
        set_param('AdvisoryControl/Step', 'After', num2str(decelLim_hcw*1.1));
        simModel_new_hcw = sim('AdvisoryControl.slx');
        Ta_hcw = simModel_new_hcw.sx1.Time(end);

        h_stop_hcw = Ta_hcw + curr_Tr_HCW;
        disp("H stop for HCW is " + h_stop_hcw)

        if lastDistance_hcw >= 0
            if h_stop_hcw < lastTime_hcw
            switchCount_hcw = switchCount_hcw + 1;
            disp("Switch to Human")
            else
                disp("Do not switch")
            end
        else
            disp("Do not switch")
        end
    end

    if switchCount_lcw < minSwitchCount_lcw
        minSwitchCount_lcw = switchCount_lcw;
        bestGain_lcw = Gain;
    end

    if switchCount_hcw < minSwitchCount_hcw
        minSwitchCount_hcw = switchCount_hcw;
        bestGain_hcw = Gain;
    end
end