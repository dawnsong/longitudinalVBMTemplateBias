# Possible Template Bias In Longitudinal VBM studies for developmental studies
## Brief motivation
In the cross-sectional studies, the template can be simply the population average. However, treating longitudinal scans as independent scans as in cross-sectional studies may smear the subtle changes along the time, which is essentially what longtitudinal studies care most about.
Though there have been discussions on the possible bias caused by different ways of building a template in longitudinal studies [Reuter et al., 2011, 2012; Ashburner and Ridgway 2013; Scott et al., 2016; Ball et al., 2019], the template choice has not been studied yet, especially for brain developmental studies, and with non-linear registration involved 

## The rational behind the simulation
For the registration, we assume the registration can do perfectly job though there is actually no manipulation of any linear/non-linear registration parameters. With only the manipulation of the intensity values, with different choice of template (subject-specific or age-specific), there will be different estimation results.

## How to reference this work:

Xiaowei Song, Pamela Garcia, Nathan Kindred, Yujiang Wang, Hugo Merchant, Adrien Meguerditchian,  Yihong Yang, Elliot A. Stein, Charles W. Bradberry, Suliann Ben Hamed, Hank P. Jedema, Colline Poirier. "Strengths and challenges of longitudinal primate neuroimaging". Submitted to ...

## Code organization
There are usually two stages in longitudinal VBM registration (Fig. 0). And it is critical to build/choose a template in the 1st stage. As shown in the simulation, there maybe bigger bias when choosing subject-specific template (Fig. 1, Fig. 2A,2B) 

![fig0-2stages](./figS1-colline-2-ways.png)
Fig. 0. different combinations of templates for the 2 stages in longitudinal VBM

![fig1-stage1-nonlinearBias](./sim4aging_a0.1s0.1/cmpAgeSubjSpecificTemplate4diff2gt-wErrBars.png)
Fig. 1


![fig2a-stage2](./sim4aging_a0.1s0.1/stage2-FLIRTavg2popAvg/2ndStage-optionA-cmpAgeSubjSpecificTemplate4diff2gt-wErrBars.png)
Fig. 2A.
![fig2b-stage2](./sim4aging_a0.1s0.1/stage2-avg2alignPopAvg/2ndStage-optionB-cmpAgeSubjSpecificTemplate4diff2gt-wErrBars.png)
Fig. 2B.


### Note
My script plRunCmd is in this dir and should be added to PATH env, pexec (parallel execution cmd) should also be installed. Note that plRunCmd is nothing but adding cmd history into resulted NIFTI file header, thus it can be ignored or deleted. It is included here just for reference.
The code are organized in two folders and each reprsent a stage as the folder name.

## How to run the code
To repeat the figures' results: just follow the number of the script.

Xiaowei Song
version: Jul 21, 2020

## Dependencies:
1. AFNI [http://afni.nimh.nih.gov]
2. FSL [ Andersson et al., 2017 ]
3. FreeSurfer [Reuter et al., 2011; 2012]
4. INIA-19 template [Rohlfing et al., 2012]
5. Liu & Liang (1997) power simulation package by Dr. Michael C. Donohue (mdonohue@usc.edu): https://github.com/mcdonohue/longpower .

## Key References:
1. Reuter, M., Fischl, B., 2011. Avoiding asymmetry-induced bias in longitudinal image processing. NeuroImage 57, 19–21. https://doi.org/10.1016/j.neuroimage.2011.02.076

2. Reuter, M., Schmansky, N.J., Rosas, H.D., Fischl, B., 2012. Within-subject template estimation for unbiased longitudinal image analysis. NeuroImage 61, 1402–1418. https://doi.org/10.1016/j.neuroimage.2012.02.084

3. Rohlfing, T., Kroenke, C.D., Sullivan, E.V., Bowden, D.M., Grant, K.A., 2012. The INIA19 template and NeuroMaps atlas for primate brain image parcellation and spatial normalization. Front. Neuroinform. 6, 27. https://doi.org/10.3389/fninf.2012.00027

4. Ashburner, J., Ridgway, G.R., 2013. Symmetric Diffeomorphic Modeling of Longitudinal Structural MRI. Front Neurosci 6. https://doi.org/10.3389/fnins.2012.00197

5. Andersson, J.L., Jenkinson, M., Smith, S., 2007. Non-linear registration aka Spatial normalisation FMRIB Technial Report TR07JA2. FMRIB Analysis Group of the University of Oxford.

6. Scott, J.A., Grayson, D., Fletcher, E., Lee, A., Bauman, M.D., Schumann, C.M., Buonocore, M.H., Amaral, D.G., 2016. Longitudinal analysis of the developing rhesus monkey brain using magnetic resonance imaging: birth to adulthood. Brain Struct Funct 221, 2847–2871. https://doi.org/10.1007/s00429-015-1076-x

7. Ball, G., Seal, M.L., 2019. Individual variation in longitudinal postnatal development of the primate brain. Brain Struct Funct 224, 1185–1201. https://doi.org/10.1007/s00429-019-01829-5

8. Liu, G., & Liang, K. Y. (1997). Sample size calculations for studies with correlated observations. Biometrics, 53(3), 937-47.

9. Michael C. Donohue.  https://cran.r-project.org/web/packages/longpower/index.html
