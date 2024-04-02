import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMonthlyUserData from '@salesforce/apex/LeaderReportsController.getMonthlyUserData';
import getMonthlyUserQuarterData from '@salesforce/apex/LeaderReportsController.getMonthlyUserQuarterData';
import refreshData from '@salesforce/apex/LeaderReportsController.refreshData';


export default class LeaderReports extends LightningElement {
    @track title = '';
    @track isLoading = false;
    @track isSalesData = false;
    @track isPrcurementData = false;
    @track isSalesQuarterData = false;
    @track isPrcurementQuarterData = false;
    @track YearValue;
    @track yearOptions = [];
    @track parentData = [];
    @track parentQuarterData = [];
    @track saleLeaderData = [];
    @track saleQuarterLeaderData = [];
    @track ProcurementLeaderData = [];
    @track ProcurementQuarterLeaderData = [];
    //@track quarterOption;


    @track QuarterActionValue;

    @track defaultStartYear = new Date().getFullYear();

    get quarterOption() {
        return [
            { label: 'Quarter 1', value: 'Quarter 1' },
            { label: 'Quarter 2', value: 'Quarter 2' },
            { label: 'Quarter 3', value: 'Quarter 3' },
            { label: 'Quarter 4', value: 'Quarter 4' }
        ];
    }

    connectedCallback() {
        this.setYearOption();

        //this.getPicklistOptions();
        this.getCurrentQuarter();
        //to get current Data
        this.getMonthlyData(this.defaultStartYear, this.QuarterActionValue);
        this.getQuarterData(this.defaultStartYear);
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
        const toggleList = this.template.querySelectorAll('c-show-leader-report-data');
        for (const toggleElement of toggleList) {
            toggleElement.getCurrentQuarter(quarter);
        }
    }

    setYearOption() {
        let yearOptions = [];
        for (let start = 2020; start <= this.defaultStartYear; start++) {
            yearOptions.push({ label: start, value: start });
        }
        this.yearOptions = yearOptions;
    }
    captureYearActionChange(event) {
        this.defaultStartYear = parseInt(event.detail.value);
    }
    captureQuarterActionChange(event) {
        this.QuarterActionValue = event.detail.value;
    }
    hanldeApply() {
        this.saleLeaderData = [];
        this.saleQuarterLeaderData = [];
        this.ProcurementLeaderData = [];
        this.ProcurementQuarterLeaderData = [];
        this.getMonthlyData(this.defaultStartYear, this.QuarterActionValue);
        this.handleQuaterUpdate(this.QuarterActionValue);
        this.getQuarterData(this.defaultStartYear);
    }
    getMonthlyData(year, Quarter) {
        this.isLoading = true;
        getMonthlyUserData({ Year: year, Quarter: Quarter })
            .then(result => {
                if (result.isSuccess) {
                    console.log('res :', result);
                    let data = JSON.parse(result.response);
                    if (data.saleLeaderData != null) {
                        if (data.saleLeaderData.MonthTotal.length == 0) {
                            this.isSalesData = false;
                            this.pageMessage = 'No Record Found(s).';
                        } else {
                            this.isSalesData = true;
                            this.saleLeaderData = data.saleLeaderData;
                            //this.getMonthNames(this.saleLeaderData);
                        }
                    }
                    if (data.ProcurementLeaderData != null) {
                        if (data.ProcurementLeaderData.MonthTotal.length == 0) {
                            this.isPrcurementData = false;
                            this.pageMessage = 'No Record Found(s).';
                        } else {
                            this.isPrcurementData = true;
                            this.ProcurementLeaderData = data.ProcurementLeaderData;
                            //this.getMonthNames(this.saleLeaderData);
                        }
                    }else{
                         this.isSalesData = false;
                    this.isPrcurementData = false;
                    this.pageMessage = 'No Record Found(s).';
                    }
                } else {
                    //this.listOfWeekGroup.push({WeekTitle: this.weekTitle, listOfRecords: null});
                    this.pageMessage = result.message;

                    this.showToast('error', result.message, result.response);
                }
                this.isLoading = false;
            }).catch(error => {
                //this.listOfWeekGroup.push({ WeekTitle: this.weekTitle, listOfRecords: null });

                this.showToast('error', 'Error', error.response);
                this.pageMessage = JSON.stringify(error);
                this.isLoading = false;
            })
    }

    getQuarterData(year) {
        this.isLoading = true;
        getMonthlyUserQuarterData({ Year: year })
            .then(result => {
                if (result.isSuccess) {
                    console.log('res :', result);
                    let data = JSON.parse(result.response);
                    if (data.saleLeaderData != null) {
                        if (data.saleLeaderData.QuarterTotal.length == 0) {
                            this.isSalesQuarterData = false;
                            this.pageMessage = 'No Record Found(s).';
                        } else {
                            this.isSalesQuarterData = true;
                            this.saleQuarterLeaderData = data.saleLeaderData;
                            //this.getMonthNames(this.saleLeaderData);  
                        }
                    }
                    if (data.ProcurementLeaderData != null) {
                        if (data.ProcurementLeaderData.QuarterTotal.length == 0) {
                            this.isPrcurementQuarterData = false;
                            this.pageMessage = 'No Record Found(s).';
                        } else {
                            this.isPrcurementQuarterData = true;
                            this.ProcurementQuarterLeaderData = data.ProcurementLeaderData;
                            //this.getMonthNames(this.saleLeaderData);
                        }
                    }else{
                        this.isPrcurementQuarterData = false;
                    this.isSalesQuarterData = false;
                    this.pageMessage = 'No Record Found(s).';
                    }
                    
                } else {
                    //this.listOfWeekGroup.push({WeekTitle: this.weekTitle, listOfRecords: null});
                    this.pageMessage = result.message;

                    this.showToast('error', result.message, result.response);
                }
                this.isLoading = false;
            }).catch(error => {
                //this.listOfWeekGroup.push({ WeekTitle: this.weekTitle, listOfRecords: null });

                this.showToast('error', 'Error', error.response);
                this.pageMessage = JSON.stringify(error);
                this.isLoading = false;
            })
    }

    hanldeRefreshClick(){
         refreshData({Year: this.defaultStartYear
    })
      .then(result => {
        //this.optionThType = result;
        let message = 'Reload the Window after 2 to 5 minutes to get refersh data.';
        this.showToast('success', 'Success', message);
      })
      .catch(error => {

        this.showToast('error', 'Error', error.body);

      });
    }

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