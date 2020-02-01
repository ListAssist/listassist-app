import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Timestamp = admin.firestore.Timestamp;

const db = admin.firestore();

export const createAutomaticList = functions.region("europe-west1").https.onCall(async (data, context) => {
    const uid = context.auth.uid;

    //TODO: Call Method at times that make sense (every start?)

    //TODO: If necessary also save and add category of products

    //TODO: Create settings field to read data
    //const userDoc = await db.collection("users").doc(uid).get();
    //const days = userDoc.data()["settings"]["INSERT NAME"];
    //const last = userDoc.data()["settings"]["last_generated"];

    // if (days) {
    //     // Not enough days since the last automatic list have passed.
    //     if(days - last > 0) return { status: "Failed" };
    // }

    //TODO: Increase from 5 to 10 Lists
    const lists = await loadLists(uid, 5);
    if(!lists || lists.length < 5) {
        return {status: "Failed"};
    }

    const recommendedItems = recommend(lists);

    const today = new Date(Date.now());

    const newList = {
        created: Timestamp.now(),
        name: `Autogenerierte Liste ${("00" + today.getDate()).substr(-2)}.${("00" + (today.getDate() + 1)).substr(-2)}.${today.getFullYear()}`,
        type: "pending",
        items: recommendedItems
    };

    if(recommendedItems.length === 0){
        return { status: "Failed" };
    }

    return db.collection("users").doc(uid).collection("lists").add(newList).catch(() => {
        return { status: "Failed" };
    }).then(() => {
        //TODO: Delete every list older/other than the latest 10
        return { status: "Successful" };
    });

});

async function loadLists(uid: string, amount: number) {
    try{
        const file: any = await db.collection("users").doc(uid).collection("shopping_data").doc("data").get();
        return file.data()["last"].splice(-amount);
    }catch (e) {
        return [];
    }
}

function recommend(lists: object[]) {
    let recommendation: any = [];

    //@ts-ignore
    const firstDay: Date = lists[0]["completed"].toDate();
    //@ts-ignore
    const lastDay: Date = lists[lists.length - 1]["completed"].toDate();

    const today: Date = new Date(Date.now());

    // Timespan in days between the first and last shopping
    //@ts-ignore
    const timeSpan = Math.ceil(Math.abs(lastDay - firstDay) / (1000 * 60 * 60 * 24));

    const itemFrequency: object = calculateFrequency(lists, timeSpan);

    Object.keys(itemFrequency).forEach(i => {
        const next: Date = getLastDateWithItem(lists, i);
        //@ts-ignore
        next.setDate(next.getDate() + itemFrequency[i]);
        //@ts-ignore
        const timeDiffToToday = Math.ceil(Math.floor(today - next) / (1000 * 60 * 60 * 24));
        //@ts-ignore
        //console.log(i, getLastDateWithItem(lists, i), itemFrequency[i], timeDiffToToday);
        //TODO: Change from 5 to 10 and 2 to 5
        //@ts-ignore
        if ((timeDiffToToday >= 0 || timeDiffToToday + 5 <= 2) && (itemFrequency[i] <= timeSpan/2)) {
            recommendation.push(
                {
                    //@ts-ignore
                    count: timeDiffToToday === 0 ? 1 : Math.round(timeDiffToToday / itemFrequency[i]),
                    name: i,
                    bought: false
                }
            );
        }
    });

    //@ts-ignore
    recommendation = recommendation.filter(p => p["count"] > 0);
    return recommendation;
}

function calculateFrequency(lastLists: object[], days: number) {
    const itemFrequency: object = {};

    for (const list of lastLists) {
        //@ts-ignore
        for (const item of list["items"]) {
            //@ts-ignore
            itemFrequency[item["name"]] = itemFrequency[item["name"]]
                //@ts-ignore
                ? itemFrequency[item["name"]] + item["count"]
                //@ts-ignore
                : item["count"];
        }
    }

    for (const key in itemFrequency) {
        //@ts-ignore
        itemFrequency[key] = Math.round(1 / (itemFrequency[key] / days));
    }

    return itemFrequency;
}

function getLastDateWithItem(lastLists: object[], name: string) {
    const lastPossibilities: Date[] = [];

    lastLists.forEach((el, index) => {
        //@ts-ignore
        if (el["items"].map(i => i["name"]).includes(name)) {
            //@ts-ignore
            lastPossibilities.push(lastLists[index]["completed"].toDate());
        }
    });

    //@ts-ignore
    return new Date(Math.max(...lastPossibilities));
}

