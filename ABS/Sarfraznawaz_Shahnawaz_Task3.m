clc
clear all

bestFactor = 0.0100;
numSamples = 100;
speeds = randi([20,60],1,numSamples);
decelLim_lcw = -200;
decelLim_hcw = -150;
totalCollision = inf;

P = [0.6 0.4; 0.85 0.15];
mc = dtmc(P);
roadConditions = simulate(mc, numSamples);
roadConditions = roadConditions(2:end); 

bestGain_lcw = NaN;
bestGain_hcw = NaN;

% USER 3 - LCW
hr_lcw = normrnd(61, 14, 1, numSamples);
rr_lcw = normrnd(17, 8, 1, numSamples);
rq_lcw = hr_lcw./rr_lcw;
tr_lcw = rq_lcw*bestFactor;


% USER 3 - HCW
hr_hcw = normrnd(92, 23, 1, numSamples);
rr_hcw = normrnd(26, 16, 1, numSamples);
rq_hcw = hr_hcw./rr_hcw;
tr_hcw = rq_hcw*bestFactor;

minSwitchCount_lcw = inf;
minSwitchCount_hcw = inf;

% Calculating the best gain for both HCW and LCW 
for Gain = 10000:10000:100000
    [A,B,C,D,Kess, Kr, Ke, uD] = designControl(secureRand(),Gain);
    open_system('LaneMaintainSystem.slx')
    load_system('HumanActionModel.slx');
    switchCount_lcw = 0;
    switchCount_hcw = 0;
    collision = 0;
    for i = 1:100
        if roadConditions(i)==1
            tr = tr_lcw(i);
            speed = speeds(i);
            set_param('LaneMaintainSystem/VehicleKinematics/Saturation','LowerLimit',num2str(decelLim_lcw))
            set_param('LaneMaintainSystem/VehicleKinematics/vx','InitialCondition',num2str(speed))
            simModel_lcw = sim('LaneMaintainSystem.slx');

            lastDistance = simModel_lcw.sx1.Data(end);
            lastTime = simModel_lcw.sx1.Time(end);
            for t = 1:length(simModel_lcw.sx1.Time)
                distance = simModel_lcw.sx1.Data(t);
                if distance > 0
                    lastTime = simModel_lcw.sx1.Time(t);
                    break; % Exit the loop as soon as distance exceeds 0
                end
            end

            % Importing the VehicleModelOnly.slx file to calculate the Action Time (Ta)
            % LCW
            set_param('HumanActionModel/Step', 'Time', num2str(tr));
            set_param('HumanActionModel/Step', 'After', num2str(decelLim_lcw*1.1));
            simModel_new_lcw = sim('HumanActionModel.slx');
            ta = simModel_new_lcw.sx1.Time(end);

            h_stop = ta + tr;
            disp("H stop for LCW is " + h_stop);

            if lastDistance >= 0
                if h_stop < lastTime
                switchCount_lcw = switchCount_lcw + 1;
                disp("No Collision. Switch to Human")
                else
                    disp("Collision Occured")
                    collision = collision+1;
                end
            else
                disp("No Collision Occured.")
            end
        else
            tr = tr_hcw(i);
            speed = speeds(i);
            set_param('LaneMaintainSystem/VehicleKinematics/Saturation','LowerLimit',num2str(decelLim_hcw))
            set_param('LaneMaintainSystem/VehicleKinematics/vx','InitialCondition',num2str(speed))
            simModel_lcw = sim('LaneMaintainSystem.slx');

            lastDistance = simModel_lcw.sx1.Data(end);
            lastTime = simModel_lcw.sx1.Time(end);
            for t = 1:length(simModel_lcw.sx1.Time)
                distance = simModel_lcw.sx1.Data(t);
                if distance > 0
                    lastTime = simModel_lcw.sx1.Time(t);
                    break; % Exit the loop as soon as distance exceeds 0
                end
            end

            % Importing the VehicleModelOnly.slx file to calculate the Action Time (Ta)
            % HCW
            set_param('HumanActionModel/Step', 'Time', num2str(tr));
            set_param('HumanActionModel/Step', 'After', num2str(decelLim_hcw*1.1));
            simModel_new_lcw = sim('HumanActionModel.slx');
            ta = simModel_new_lcw.sx1.Time(end);

            h_stop = ta + tr;
            disp("H stop for HCW is " + h_stop);

            if lastDistance >= 0
                if h_stop < lastTime
                switchCount_hcw = switchCount_hcw + 1;
                disp("No Collision. Switch to Human")
                else
                    disp("Collision Occured")
                    collision = collision+1;
                end
            else
                disp("No Collision Occured.")
            end
        end
    end

    if switchCount_lcw<minSwitchCount_lcw
        minSwitchCount_lcw = switchCount_lcw;
        bestGain_lcw = Gain;
    end

    if switchCount_hcw<minSwitchCount_hcw
        minSwitchCount_hcw = switchCount_hcw;
        bestGain_hcw = Gain;
    end

    if collision<totalCollision
        totalCollision = collision;
    end
end

disp("Best Gain for LCW = " + bestGain_lcw);
disp("Best Gain for HCW = " + bestGain_hcw);
disp("Total Collision = " + totalCollision);
disp("Switch Count for LCW = " +  minSwitchCount_lcw);
disp("Switch Count for HCW = " +  minSwitchCount_hcw);

