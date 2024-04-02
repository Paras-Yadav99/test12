import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import getUserOptions from '@salesforce/apex/LeaderBoardForUserController.getUserOptions';
//import getUserAnualGraphData from '@salesforce/apex/LeaderBoardForUserController.getUserAnualGraphData';
import getUserQuarterData from '@salesforce/apex/LeaderBoardForUserController.getUserQuarterData';


export default class LeaderBoardForUser extends LightningElement {
    @track title = '';
    @track isLoading = false;
    @track isQuarterSelected = false;
    @track defaultStartYear = new Date().getFullYear();
    @track yearOptions = [];
    @track QuarterActionValue;
    @track parentData = [];
    @track parentQuarterData = [];
    @track saleLeaderData = [];
    @track ProcurementLeaderData = [];
    @track userOption = [];
    @track selectedUser = Id;
    @track chartConfiguration;
    @track chartConfigurationProc;
    @track salesMonthlyDataLst = [];
    @track procurmentMonthlyDataLst = [];
    @track isSalesMonthlyData = false;
    @track isProcurmentMonthlyData = false;
    @track userId = Id;
    @track userName;
    @track userRoleName;
    @track userProfileName;
    @track disableUserPicklist = true;


    get quarterOption() {
        return [
            { label: '-- NONE --', value: 'NONE' },
            { label: 'Quarter 1', value: 'Quarter 1' },
            { label: 'Quarter 2', value: 'Quarter 2' },
            { label: 'Quarter 3', value: 'Quarter 3' },
            { label: 'Quarter 4', value: 'Quarter 4' }
        ];
    }

    connectedCallback() {
        this.isLoading = true;
        //this.init();
        this.setYearOption();
        this.getCurrentQuarter();

        this.handleUserOptipon(this.defaultStartYear);
        this.isQuarterSelected = true;
        this.handleGetGraphQuarterData(this.defaultStartYear, this.selectedUser, this.QuarterActionValue);
        // this.isLoading = false;
    }

     @wire(getRecord, { recordId: Id, fields: [Name,  ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.Name.value != null) {
                this.userName = data.fields.Name.value;
            }
            if (data.fields.Profile.value != null) {
                this.userProfileName = data.fields.Profile.value.fields.Name.value;
                this.handleUserValidation(this.userProfileName);
            }
            
        }
    }

   

 /*   @wire(getUserInfo, { userId: this.selectedUser })
  wiredUserInfo({ error, data }) {
    if (data) {
      this.userName = data.fields.Name.value;
    } else if (error) {
      console.error('Error retrieving user information:', error);
    }
  }*/

    handleUserValidation(pfName){
        if(pfName =='System Administrator'){
            this.disableUserPicklist = false;
        }else{
            this.disableUserPicklist = true;
        }
    }

    onChange(){
        this.isSalesMonthlyData = false;
        this.isProcurmentMonthlyData = false;
        if (this.QuarterActionValue  != 'NONE') {
            this.isQuarterSelected = true;
            this.handleQuaterUpdate(this.QuarterActionValue);
        } else {
            this.isQuarterSelected = false;
            this.handleQuaterUpdate(this.QuarterActionValue);
        }
    }



    getCurrentQuarter() {
        let today = new Date();
        let thisMonth = today.toLocaleString('default', { month: 'long' });

        if (thisMonth == 'January' || thisMonth == 'February' || thisMonth == 'March') {
            this.QuarterActionValue = 'Quarter 1';
            this.handleQuaterUpdate(this.QuarterActionValue);
        } else if (thisMonth == 'April' || thisMonth == 'May' || thisMonth == 'June') {
            this.QuarterActionValue = 'Quarter 2';
            this.handleQuaterUpdate(this.QuarterActionValue);
        } else if (thisMonth == 'July ' || thisMonth == 'August' || thisMonth == 'September') {
            this.QuarterActionValue = 'Quarter 3';
            this.handleQuaterUpdate(this.QuarterActionValue);

        } else if (thisMonth == 'October' || thisMonth == 'November' || thisMonth == 'December') {
            this.QuarterActionValue = 'Quarter 4';
            this.handleQuaterUpdate(this.QuarterActionValue);
        }
    }

    //c-show-leader-report-data
    handleQuaterUpdate(quarter) {
        const toggleList = this.template.querySelectorAll('c-show-data-leader-board-for-user');
        for (const toggleElement of toggleList) {
            toggleElement.getCurrentQuarter(quarter);
        }
    }




    handleUserOptipon(year) {
        //this.isLoading = true;
        getUserOptions({ Year: year })
            .then(result => {
                if (result.isSuccess) {
                    this.userOption = JSON.parse(result.response);
                    this.isLoading = false;
                }
            }).catch(error => {
                this.showToast('error', 'Error', error.response);
                this.isLoading = false;

            })
    }
    captureQuarterActionChange(event) {
        this.QuarterActionValue = event.detail.value;
     /*   if (event.detail.value != 'NONE') {
            this.isQuarterSelected = true;
            console.log('IsQuarterSlected ::::' + this.isQuarterSelected);
            this.QuarterActionValue = event.detail.value;
            this.handleQuaterUpdate(this.QuarterActionValue);
        } else {
            this.isQuarterSelected = false;
            console.log('IsQuarterSlected ::::' + this.isQuarterSelected);
            this.handleQuaterUpdate(this.QuarterActionValue);
        }
        //this.onChange();*/
    }
    captureUserChange(event) {
        this.selectedUser = event.detail.value;
        //this.userName = event.detail.label;
        this.userName = this.userOption.find(
            option => option.value === this.selectedUser
          ).label;
        console.log('this.selectedUser :::' + this.selectedUser);
        console.log('this.selectedUser userName:::' + this.userName);
        //this.onChange();

    }
    hanldeApply() {
        this.onChange();
        this.salesMonthlyDataLst = [];
        this.procurmentMonthlyDataLst = [];
        this.chartConfiguration = '';
        this.chartConfigurationProc = '';
        this.isLoading = true;
        if (this.selectedUser != null) {
            if (this.isQuarterSelected) {
                this.handleGetGraphQuarterData(this.defaultStartYear, this.selectedUser, this.QuarterActionValue);
            } else {
                this.handleGetGraphData(this.defaultStartYear, this.selectedUser);
            }
        } else {

            this.showToast('error', 'Error', 'User Id not Found! Please Select a User First.');
            this.isLoading = false;
        }
        //this.isLoading = false;
    }

    handleGetGraphData(year, userId) {
        this.saleLeaderData = [];
        this.ProcurementLeaderData = [];
        this.chartConfiguration = '';
        this.chartConfigurationProc = '';
        getUserQuarterData({ Year: year, UserId: userId, Quarter: null ,IsQuarter : false})
            .then(result => {
                console.log('result Before::' + JSON.stringify(result));
                if (result.isSuccess) {
                    console.log('result::' + JSON.stringify(result));
                    let data = JSON.parse(result.response);
                    this.saleLeaderData = data.saleLeaderData;
                    this.ProcurementLeaderData = data.ProcurementLeaderData;
                    this.salesMonthlyDataLst = data.lstSaleLeaderData;
                    this.procurmentMonthlyDataLst = data.lstProcurmentLeaderData;

                    console.log('this.salesMonthlyDataLst ::::' + JSON.stringify(this.salesMonthlyDataLst));
                    if (this.salesMonthlyDataLst.length > 0) {
                        this.isSalesMonthlyData = true;
                    }
                    if(this.procurmentMonthlyDataLst.length > 0){
                        this.isProcurmentMonthlyData = true;
                    }
                    this.chartConfiguration = this.returnGraphData(this.saleLeaderData);
                    this.chartConfigurationProc = this.returnGraphData(this.ProcurementLeaderData);

                    this.error = undefined;
                    this.isLoading = false;
                }
                else {
                    this.showToast('error', result.message, result.response);
                    this.isLoading = false;
                }
            })
            .catch(error => {
                //this.spinnerToggle();
                this.showToast('error', error.message, error.body);
                this.isLoading = false;
            });
    }
    @track saleLeaderQuarterData = [];
    @track ProcurementLeaderQuarterData = [];
    @track chartConfigurationSalesQ1;
    @track chartConfigurationProcQ1;

    handleGetGraphQuarterData(year, userId, quarter) {
        this.saleLeaderQuarterData = [];
        this.ProcurementLeaderQuarterData = [];

        // this.chartConfigurationSalesQ1 = '';
        // this.chartConfigurationProcQ1 = '';

        this.chartConfiguration = '';
        this.chartConfigurationProc = '';
        getUserQuarterData({ Year: year, UserId: userId, Quarter: quarter ,IsQuarter : true})
            .then(result => {
                console.log('result Before::' + JSON.stringify(result));
                if (result.isSuccess) {
                    console.log('result::' + JSON.stringify(result));
                    let data = JSON.parse(result.response);
                    this.saleLeaderQuarterData = data.saleLeaderData;
                    this.ProcurementLeaderQuarterData = data.ProcurementLeaderData;
                    this.salesMonthlyDataLst = data.lstSaleLeaderData;
                    this.procurmentMonthlyDataLst = data.lstProcurmentLeaderData;

                    console.log('this.salesMonthlyDataLst ::::' + JSON.stringify(this.salesMonthlyDataLst));
                    if (this.salesMonthlyDataLst.length > 0) {
                        this.isSalesMonthlyData = true;
                    }
                    if(this.procurmentMonthlyDataLst.length > 0){
                        this.isProcurmentMonthlyData = true;
                    }

                    this.chartConfiguration = this.returnGraphData(this.saleLeaderQuarterData);
                    this.chartConfigurationProc = this.returnGraphData(this.ProcurementLeaderQuarterData);
                    //this.chartConfigurationSalesQ1 =this.returnGraphData(this.saleLeaderQuarterData);
                    //this.chartConfigurationProcQ1 = this.returnGraphData(this.ProcurementLeaderQuarterData);

                    this.error = undefined;
                    this.isLoading = false;
                }
                else {
                    this.showToast('error', result.message, result.response);
                    this.isLoading = false;
                }
            })
            .catch(error => {
                //this.spinnerToggle();
                this.showToast('error', error.message, error.body);
                this.isLoading = false;
            });
    }

    returnGraphData(Inputdata) {
        let data;
        let chartGPGData = [];
        let chartGPData = [];
        let chartLabel = [];
        Inputdata.forEach(eachUserMonthlyData => {
            chartGPGData.push(eachUserMonthlyData.goal);
            chartGPData.push(eachUserMonthlyData.gP);
            chartLabel.push(eachUserMonthlyData.Month);
        });

        data = {
            type: 'bar',
            data: {
                datasets: [{
                    label: 'GrossProfitGoal',
                    backgroundColor: "green",
                    data: chartGPGData,
                },
                {
                    label: 'GrossProfit',
                    backgroundColor: "orange",
                    data: chartGPData,
                },
                ],
                labels: chartLabel,
            },
            options: {},
        };

        return data;
    }
    //year picklist value
    setYearOption() {
        let yearOptions = [];
        for (let start = 2020; start <= this.defaultStartYear; start++) {
            yearOptions.push({ label: start, value: start });
        }
        this.yearOptions = yearOptions;
    }

    captureYearActionChange(event) {
        this.defaultStartYear = parseInt(event.detail.value);
        this.handleUserOptipon(this.defaultStartYear);
        this.selectedUser = '';
       // this.onChange();
    }

    // Show Toast
    showToast(variant,
        title,
        message) {
        const event = new ShowToastEvent({
            variant: variant,
            title: title,
            message: message,
        });
        this.dispatchEvent(event);
    }
}