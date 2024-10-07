/* eslint-disable @typescript-eslint/no-unused-vars */
import { createRouteHandler } from "uploadthing/next";
import { ourFileRouter } from "./core";
import { NextRequest, NextResponse } from "next/server";

// Create the UploadThing route handler
const uploadThingHandler = createRouteHandler({
  router: ourFileRouter,
});

async function loggingMiddleware(req: NextRequest, method: "GET" | "POST") {
  console.log(`[${method}] ${req.url} - Request received`);
  console.log(
    "Headers:",
    JSON.stringify(Object.fromEntries(req.headers), null, 2)
  );

  if (method === "POST") {
    const contentType = req.headers.get("content-type");
    console.log("Content-Type:", contentType);
    if (contentType && contentType.includes("multipart/form-data")) {
      try {
        const formData = await req.formData();
        console.log("Form data keys:", Array.from(formData.keys()));
        formData.forEach((value, key) => {
          if (value instanceof File) {
            console.log(`File ${key}:`, value.name, value.type, value.size);
          } else {
            console.log(`Field ${key}:`, value);
          }
        });
      } catch (error) {
        console.error("Error parsing form data:", error);
      }
    }
  }

  // Pass the request to UploadThing handler
  try {
    const response = await uploadThingHandler[method](req);
    console.log(`[${method}] ${req.url} - Response status:`, response.status);
    return response;
  } catch (error) {
    console.error(`[${method}] ${req.url} - Error:`, error);
      if (error instanceof Error) {
        console.log(error.message)
      return NextResponse.json({ error: error.message }, { status: 400 });
    }
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}

export async function GET(req: NextRequest) {
  return uploadThingHandler.GET(req);
}

export async function POST(req: NextRequest) {
  return uploadThingHandler.POST(req);
}
