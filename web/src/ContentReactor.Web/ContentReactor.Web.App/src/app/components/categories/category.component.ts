import { Component, Input} from '@angular/core';
import { HttpClient, HttpResponse } from '@angular/common/http';
import { trigger, animate, style, group, animateChild, query, stagger, transition, state} from '@angular/animations';
import { environment } from '../../../environments/environment';
import { DataService } from '../../services/data.service';
import { HubService } from '../../services/hub.service';
import { Router } from '@angular/router';
import { Category } from './category';
import { ImageItem } from '../items/image.item';
import { TextItem } from '../items/text.item';
import { AudioItem } from '../items/audio.item';
import { AppInsightsService } from '../../services/app-insights.service';

@Component({
    selector: 'app-categories',
    templateUrl: './category.component.html',
    styleUrls: ['./category.component.css'],
    animations: [
        trigger('fadeshow', [
            transition(':enter', [
                style({ opacity: 0 }),
                animate('1000ms ease-in', style({ opacity: 1 }))
            ]),
            transition(':leave', [
                style({ opacity: 1 }),
                animate('1000ms ease-in', style({ opacity: 0 }))
            ])
        ])
    ]
})

export class CategoryComponent {

    injectedUserId: string;
    add: boolean;
    categoryName: string;
    updatedCategoryName: string;
    category_post_url: string;
    cr_created_success: boolean;
    addDisabled: boolean;
    nrOfTags: number;
    synonyms: Array<string>;
    categoriesList: Array<Category>;
    loaded = false;
    displayUserId: string;
    errorMessage: string;

    constructor(
        private router: Router,
        private data: DataService,
        private hub: HubService,
        private appInsightsService: AppInsightsService,
        private http: HttpClient
    ) {
        this.cr_created_success = false;
        this.addDisabled = false;
        this.categoriesList = new Array<Category>();
        this.appInsightsService.logPageView('Categories Page');
    }

    ngOnInit() {

        this.data.currentUser.subscribe(injectedUserId => {
                this.injectedUserId = injectedUserId;
        });
        this.category_post_url = environment.apiUrl + '/api/Category?userId=' + this.injectedUserId;
    }


    ngAfterContentInit() {
        this.displayUserId = this.injectedUserId.split('@')[0];
        this.listenToEvents();
        this.getAllCategories();
    }

    listenToEvents() {
        this.hub.getHubConnection().on('onCategorySynonymsUpdated', (categoryId: string, eventData: any) => {
            const category: Category = this.fetchCategoryObject(categoryId);
            category.setSynonyms(eventData.synonyms);
            this.appInsightsService.logEvent('Category Synonyms Updated',{category : categoryId});
        });

        this.hub.getHubConnection().on('onCategoryImageUpdated', (categoryId: string, eventData: any) => {
            const category: Category = this.fetchCategoryObject(categoryId);
            category.setImage(eventData.imageUrl);
            this.appInsightsService.logEvent('Category Image Updated',{category : categoryId});
        });

        this.hub.getHubConnection().on('onCategoryItemsUpdated', (categoryId: string, eventData: any) => {
            const category: Category = this.fetchCategoryObject(categoryId);
            category.notifications += 1;
            category.showNotification = true;
            this.appInsightsService.logEvent('Category Items Updated', {category : categoryId});
        });

        this.hub.getHubConnection().on('onCategoryCreated', (categoryId: string, eventData: any) => {
            // Add event handling code for category creation here
            this.appInsightsService.logEvent('Category Created', {category : categoryId});
        });

        this.hub.getHubConnection().on('onCategoryDeleted', (categoryId: string, eventData: any) => {
            // Add event handling code for category deletion here
            this.appInsightsService.logEvent('Category Deleted', {category : categoryId});
        });

        this.hub.getHubConnection().on('onCategoryNameUpdated', (categoryId: string, eventData: any) => {
            // Add event handling code for category update here
            this.appInsightsService.logEvent('Category Name Updated', {category : categoryId});
        });

    }

    getAllCategories(){
        const req = this.http.get(this.category_post_url)
        type CategoryType = {
            id: string,
            name: string
        };
        req.subscribe((data: any) => {
            const catListData = JSON.parse(data);
            const catList = Object.keys(catListData).map(
                function (key) {
                    const obj1: CategoryType = {} as CategoryType;
                    obj1.id = key;
                    obj1.name = catListData[key].name;
                    return obj1;
                }
            );

            for (const category of catList){
                const newCategory: Category = new Category(category.id, category.name);
                this.categoriesList.push(newCategory);
            }
            this.loaded = true;

            for (const category of catList) {
                const category_get_url = environment.apiUrl + '/api/Category/' + category.id + '/?userId=' + this.injectedUserId;
                const catReq = this.http.get(category_get_url);
                catReq.subscribe((data2: any) => {
                    const currentCategory = JSON.parse(data2);
                    const fetchedCategory: Category = this.fetchCategoryObject(currentCategory.id);
                    fetchedCategory.setImage(currentCategory.imageUrl);
                    fetchedCategory.setSynonyms(currentCategory.synonyms);
                    for (const item of currentCategory.items) {
                        if (item.type === 'Image') {
                            const c_img: ImageItem = new ImageItem(item.id);
                            c_img.setPreviewUrl(item.preview);
                            fetchedCategory.addItemImages(c_img);
                        }
                        if (item.type === 'Text') {
                            const c_txt: TextItem = new TextItem(item.id);
                            c_txt.setText(item.preview);
                            fetchedCategory.addItemText(c_txt);
                        }
                        if (item.type === 'Audio') {
                            const c_audio: AudioItem = new AudioItem(item.id);
                            c_audio.setTranscript(item.preview);
                            fetchedCategory.addItemAudio(c_audio);
                        }
                    }
                    fetchedCategory.showCategory = true;
                });
            }
        });
    }

    fetchCategoryObject(categoryId: string) {
        for (const category of this.categoriesList) {
            if (category.getId() === categoryId) {
                return category;
            }
        }
    }

    catIndexOf(categoryId: string) {
        for (let i = 0; i < this.categoriesList.length; i++) {
            if (this.categoriesList[i].id === categoryId) {
                return i;
            }
        }
    }

    onClickAddCategory() {
        if (this.categoryName === '') {
            this.errorMessage = 'Provide a valid category name. Words are good';
            return;
        }
        this.errorMessage = '';
        this.addDisabled = true;
        const req = this.http.post(this.category_post_url, {name: this.categoryName});
        req.subscribe(
            (res: any) => {
                const catId = JSON.parse((res));
                const newCategory: Category = new Category(catId.id, this.categoryName);
                this.categoriesList.push(newCategory);
                this.cr_created_success = true;
                this.addDisabled = false;
            },
            err => {
                console.log('Received error response');
            }
        );
    }

    onClickUpdateCategory(categoryId: string) {
        const category_update_url = environment.apiUrl + '/api/Category/' + categoryId + '/?userId=' + this.injectedUserId;
        const req = this.http.patch(category_update_url, {name: this.updatedCategoryName});
        req.subscribe(
            (res: any) => {
                const category: Category = this.fetchCategoryObject(categoryId);
                category.setName(this.updatedCategoryName);
                category.editMode = false;
            },
            err => {
                console.log('Received error response');
            }
        );
    }

    onClickDeleteCategory(categoryId: string) {
        const category_delete_url = environment.apiUrl + '/api/Category/' + categoryId + '/?userId=' + this.injectedUserId;
        const req = this.http.delete(category_delete_url);
        req.subscribe(
            (res: any) => {
                const index = this.catIndexOf(categoryId);
                if (index > -1) {
                    this.categoriesList.splice(index, 1);
                }
            },
            err => {
                console.log('Received error response');
            }
        );
    }

    onClickViewCategory(categoryId: string) {
        this.data.setCurrentCategory(categoryId);
        const currentCategory: Category = this.fetchCategoryObject(categoryId);
        this.data.setCurrentCategoryName(currentCategory.getName());
        this.data.clearImages();
        this.data.clearText();
        this.data.clearAudio();
        for (const item of currentCategory.getItemImages()) {
            this.data.addImage(item);
        }
        for (const item of currentCategory.getItemText()) {
            this.data.addText(item);
        }
        for (const item of currentCategory.getItemAudio()) {
            this.data.addAudio(item);
        }
        this.router.navigateByUrl('items');
    }

    onClickClearNotifications(categoryId: string) {
        const currentCategory: Category = this.fetchCategoryObject(categoryId);
        currentCategory.showNotification = false;
        currentCategory.clearNotifications();
    }

    logout() {
        // Disconnect user from signalR hub
        this.hub.getHubConnection().stop().then( () => {
            console.log('Connection stopped successfully');
            this.data.setCurrentUser('default');
            this.router.navigateByUrl('');
        }).catch(err => console.log('Error while stopping the connection'));
    }
}
