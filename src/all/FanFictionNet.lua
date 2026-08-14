-- {"id":1308639979,"ver":"1.0.6","libVer":"1.0.0","author":"Jobobby04"}

local baseURL = "https://www.fanfiction.net"
local settings = {}

local SORT_ID = 2 -- srt
local SortOptions = {
	{ name = "Update Date", value = "1" },
	{ name = "Publish Date", value = "2" },
	{ name = "Reviews", value = "3" },
	{ name = "Favorites", value = "4" },
	{ name = "Follows", value = "5" }
}

local RATING_ID = 6 -- r
local RatingOptions = {
	{ name = "All", value = "10" },
	{ name = "Rated K -> T", value = "103" },
	{ name = "Rated K -> K+", value = "102" },
	{ name = "Rated K", value = "1" },
	{ name = "Rated K+", value = "2" },
	{ name = "Rated T", value = "3" },
	{ name = "Rated M", value = "4" },
}

local TIME_RANGE_ID = 3 -- t
local TimeRangeOptions = {
	{ name = "All", value = "0" },
	{ name = "Updated within 24 hours", value = "1" },
	{ name = "Updated within 1 week", value = "2" },
	{ name = "Updated within 1 month", value = "3" },
	{ name = "Updated within 6 months", value = "4" },
	{ name = "Updated within 1 year", value = "5" },
	{ name = "Published within 24 hours", value = "11" },
	{ name = "Published within 1 week", value = "12" },
	{ name = "Published within 1 month", value = "13" },
	{ name = "Published within 6 months", value = "14" },
	{ name = "Published within 1 year", value = "15" },
}

local GENRE_A_ID = 4 -- g1
local GENRE_B_ID = 5 -- g2
local GENRE_EXCLUDE_ID = 10 -- _g1
local GenreOptions = {
	{ name = "All", value = "0" },
	{ name = "Adventure", value = "6" },
	{ name = "Angst", value = "10" },
	{ name = "Crime", value = "18" },
	{ name = "Drama", value = "4" },
	{ name = "Family", value = "19" },
	{ name = "Fantasy", value = "14" },
	{ name = "Friendship", value = "21" },
	{ name = "General", value = "1" },
	{ name = "Horror", value = "8" },
	{ name = "Humor", value = "3" },
	{ name = "Hurt/Comfort", value = "20" },
	{ name = "Mystery", value = "7" },
	{ name = "Parody", value = "9" },
	{ name = "Poetry", value = "5" },
	{ name = "Romance", value = "2" },
	{ name = "Sci-Fi", value = "13" },
	{ name = "Spiritual", value = "15" },
	{ name = "Supernatural", value = "11" },
	{ name = "Suspense", value = "12" },
	{ name = "Tragedy", value = "16" },
	{ name = "Western", value = "17" },
}
local genreByNameToValue = {}
for _, option in ipairs(GenreOptions) do
	genreByNameToValue[option.name] = option.value
end

local LANGUAGE_ID = 7 -- lan
local LanguageOptions = {
	{ name = "Language", value = "0" },
	{ name = "Bahasa Indonesia", value = "32" },
	{ name = "Català", value = "34" },
	{ name = "Deutsch", value = "4" },
	{ name = "Eesti", value = "41" },
	{ name = "English", value = "1" },
	{ name = "Español", value = "2" },
	{ name = "Esperanto", value = "22" },
	{ name = "Français", value = "3" },
	{ name = "Italiano", value = "11" },
	{ name = "Język polski", value = "13" },
	{ name = "LINGUA LATINA", value = "35" },
	{ name = "Magyar", value = "14" },
	{ name = "Nederlands", value = "7" },
	{ name = "Norsk", value = "18" },
	{ name = "Português", value = "8" },
	{ name = "Slovenčina", value = "43" },
	{ name = "Suomi", value = "20" },
	{ name = "Svenska", value = "17" },
	{ name = "čeština", value = "31" },
	{ name = "Русский", value = "10" },
	{ name = "Українська", value = "44" },
	{ name = "עברית", value = "15" },
	{ name = "ภาษาไทย", value = "38" },
	{ name = "中文", value = "5" },
	{ name = "日本語", value = "6" },
}

local LENGTH_ID = 8 -- len
local LengthOptions = {
	{ name = "All", value = "0" },
	{ name = "< 1K words", value = "11" },
	{ name = "< 5K words", value = "51" },
	{ name = "> 1K words", value = "1" },
	{ name = "> 5K words", value = "5" },
	{ name = "> 10K words", value = "10" },
	{ name = "> 20K words", value = "20" },
	{ name = "> 40K words", value = "40" },
	{ name = "> 60K words", value = "60" },
	{ name = "> 100K words", value = "100" },
}

local STATUS_ID = 9 -- s
local StatusOptions = {
	{ name = "All", value = "0" },
	{ name = "In-Progress", value = "1" },
	{ name = "Complete", value = "2" },
}

local function shrinkURL(url)
	url = url or ""
	url = url:gsub("^https?://[^/]*fanfiction%.net", "")
	url = url:gsub("^//[^/]*fanfiction%.net", "")
	return url
end

local function expandURL(url)
	url = url or ""
	if url:find("^https?://") then
		return url
	end
	if url:find("^//") then
		return "https:" .. url
	end
	if url:sub(1, 1) ~= "/" then
		url = "/" .. url
	end
	return baseURL .. url
end

local function urlEncode(str)
	if not str then
		return ""
	end
	str = str:gsub("\n", "\r\n")
	str = str:gsub("([^%w %-%_%.%~])", function(c)
		return ("%%%02X"):format(string.byte(c))
	end)
	str = str:gsub(" ", "+")
	return str
end

local function dropdownValue(options, filterValue, defaultIndex)
	local idx = tonumber(filterValue)
	if idx == nil then
		-- legacy / unexpected string name
		for i, option in ipairs(options) do
			if option.name == filterValue then
				return option.value
			end
		end
		return options[defaultIndex or 1].value
	end
	-- Shosetsu dropdowns are 0-based
	local option = options[idx + 1]
	if option == nil then
		return options[defaultIndex or 1].value
	end
	return option.value
end

--- @param element Element
--- @return Element
local function cleanupDocument(element)
	element = tostring(element):gsub('<div', '<p'):gsub('</div', '</p'):gsub('<br>', '</p><p>')
	element = Document(element):selectFirst('body')
	return element
end

local function storyIdFromURL(url)
	url = shrinkURL(url)
	return url:match("/s/(%d+)")
end

local function normalizeNovelURL(url)
	local id = storyIdFromURL(url)
	if id then
		return "/s/" .. id .. "/"
	end
	return shrinkURL(url)
end

local function chapterURL(storyId, chapterIndex)
	return "/s/" .. storyId .. "/" .. tostring(chapterIndex) .. "/"
end

--- @param chapterPath string
--- @return string
local function getPassage(chapterPath)
	local document = GETDocument(expandURL(chapterPath))
	local chap = document:selectFirst("#storytext, #storycontent, .storytextp .storytext")
	if chap == nil then
		error("Could not find story text for " .. tostring(chapterPath))
	end
	chap:select(".landmark"):remove()
	chap = cleanupDocument(chap)
	return pageOfElem(chap, true)
end

local function startsWith(str, start)
	return str:sub(1, #start) == start
end

local function split(str, delimiter)
	local result = {}
	if str == nil or str == "" then
		return result
	end
	for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
		table.insert(result, match)
	end
	return result
end

-- FanFiction separates metadata with " - " (space-hyphen-space).
local function splitMeta(query)
	local res = {}
	if query == nil then
		return res
	end
	query = query:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
	for raw in (query .. " - "):gmatch("(.-) %- ") do
		local part = raw:match("^%s*(.-)%s*$")
		if part ~= nil and part ~= "" then
			table.insert(res, part)
		end
	end
	return res
end

local function getGenres(genreString)
	if genreString == nil or genreString == "" then
		return nil
	end
	local genres = split(genreString, "/")
	for _, genre in ipairs(genres) do
		if genreByNameToValue[genre] == nil then
			return nil
		end
	end
	return genres
end

local function parseCount(value)
	if value == nil then
		return 0
	end
	if type(value) == "number" then
		return value
	end
	value = tostring(value):gsub(",", ""):gsub("%s+", "")
	return tonumber(value) or 0
end

--- @param storyInfoDocument Element
--- @return table
local function parseStoryInfo(storyInfoDocument)
	local storyInfo = storyInfoDocument:text()
	storyInfo = storyInfo:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

	local rating, language, tags, characters
	local chapterCount, wordCount, reviewCount, favCount, followsCount = 0, 0, 0, 0, 0

	local storyInfoTable = splitMeta(storyInfo)
	for k, v in ipairs(storyInfoTable) do
		if startsWith(v, "Chapters:") then
			chapterCount = v:gsub("Chapters:%s*", "")
		elseif startsWith(v, "Words:") then
			wordCount = v:gsub("Words:%s*", "")
		elseif startsWith(v, "Reviews:") then
			reviewCount = v:gsub("Reviews:%s*", "")
		elseif startsWith(v, "Favs:") then
			favCount = v:gsub("Favs:%s*", "")
		elseif startsWith(v, "Follows:") then
			followsCount = v:gsub("Follows:%s*", "")
		elseif startsWith(v, "Rated:") then
			rating = v:gsub("Rated:%s*", "")
			rating = rating:gsub("^Fiction%s+", "")
		elseif startsWith(v, "Updated:") or startsWith(v, "Published:") or startsWith(v, "id:") then
			-- ignore date/id text; timestamps come from data-xutime
		elseif k == 2 then
			language = v
		else
			if tags ~= nil then
				characters = v
			else
				tags = getGenres(v)
				if tags == nil then
					characters = v
				end
			end
		end
	end
	if characters == nil then
		characters = ""
	end
	if tags == nil then
		tags = {}
	end

	local dates = storyInfoDocument:select("span[data-xutime]")
	local updated, published = 0, 0
	if dates ~= nil and dates:size() >= 2 then
		updated = (tonumber(dates:get(0):attr("data-xutime")) or 0) * 1000
		published = (tonumber(dates:get(1):attr("data-xutime")) or 0) * 1000
	elseif dates ~= nil and dates:size() == 1 then
		published = (tonumber(dates:get(0):attr("data-xutime")) or 0) * 1000
		updated = published
	end
	local completedStatus = storyInfo:match("Status: Complete") or storyInfo:match(" %- Complete")

	chapterCount = parseCount(chapterCount)
	wordCount = parseCount(wordCount)
	reviewCount = parseCount(reviewCount)
	favCount = parseCount(favCount)
	followsCount = parseCount(followsCount)

	local characterTable = {}
	local relationshipTable = {}
	for rel_group in characters:gmatch("%[([^%]]+)%]") do
		local relationship = {}
		for rawChar in rel_group:gmatch("([^,]+)") do
			local char = rawChar:match("^%s*(.-)%s*$")
			if char ~= nil and char ~= "" then
				table.insert(characterTable, char)
				table.insert(relationship, char)
			end
		end
		table.insert(relationshipTable, relationship)
	end

	local charText = characters:gsub("%[[^%]]+%]", "")
	for rawChar in charText:gmatch("([^,]+)") do
		local char = rawChar:match("^%s*(.-)%s*$")
		if char ~= nil and char ~= "" then
			table.insert(characterTable, char)
		end
	end

	return {
		rating = rating,
		language = language,
		tags = tags,
		chapterCount = chapterCount,
		wordCount = wordCount,
		reviewCount = reviewCount,
		favCount = favCount,
		followsCount = followsCount,
		updated = updated,
		published = published,
		characters = characterTable,
		relationships = relationshipTable,
		completed = completedStatus ~= nil
	}
end

local function isPlaceholderImage(src)
	if src == nil or src == "" then
		return true
	end
	src = tostring(src):lower()
	if src:find("d_60_90", 1, true) or src:find("/static/images/", 1, true) then
		return true
	end
	if src:find("data:image", 1, true) then
		return true
	end
	return false
end

local function extractImage(element)
	if element == nil then
		return nil
	end
	local img = element
	-- If a container was passed, prefer a real story image node inside it.
	if element.selectFirst ~= nil then
		local nested = element:selectFirst("img.cimage")
				or element:selectFirst("img[data-original]")
				or element:selectFirst("img")
		if nested ~= nil then
			img = nested
		end
	end

	local attrs = { "data-original", "data-src", "data-lazy-src", "src" }
	for _, name in ipairs(attrs) do
		local src = img:attr(name)
		if src ~= nil and src ~= "" and not isPlaceholderImage(src) then
			return expandURL(src)
		end
	end
	-- Last resort: allow plain src even if it looks generic
	local src = img:attr("src")
	if src ~= nil and src ~= "" and not isPlaceholderImage(src) then
		return expandURL(src)
	end
	return nil
end

--- Prefer #profile_top / #img_large story art; fall back to raw HTML /image/ paths.
local function extractStoryImage(document, profile)
	local order = {}
	if profile ~= nil then
		table.insert(order, profile)
		table.insert(order, profile:selectFirst("img.cimage"))
		table.insert(order, profile:selectFirst("img"))
	end
	if document ~= nil then
		table.insert(order, document:selectFirst("#img_large img.cimage"))
		table.insert(order, document:selectFirst("#img_large img"))
		table.insert(order, document:selectFirst("img.cimage"))
		table.insert(order, document:selectFirst("#profile_top img"))
	end
	for _, el in ipairs(order) do
		local url = extractImage(el)
		if url ~= nil then
			return url
		end
	end
	if document == nil then
		return nil
	end
	local html = document:html()
	if html == nil then
		return nil
	end
	local path = html:match("data%-original%s*=%s*['\"](/image/[^'\"]+)['\"]")
			or html:match("data%-original%s*=%s*['\"](https?://[^'\"]+/image/[^'\"]+)['\"]")
			or html:match("src%s*=%s*['\"](/image/[^'\"]+)['\"]")
			or html:match("src%s*=%s*['\"](https?://[^'\"]+/image/[^'\"]+)['\"]")
	if path ~= nil then
		return expandURL(path)
	end
	return nil
end

--- @param storyInfoDocument Element
--- @param novelURL string
--- @param novelTitle string
--- @param thumbnail string | nil
--- @return NovelInfo
local function parseInfoDataIntoNovelInfo(storyInfoDocument, novelURL, novelTitle, thumbnail, extras)
	local infoData = parseStoryInfo(storyInfoDocument)
	local tags = {}
	if infoData.rating ~= nil and infoData.rating ~= "" then
		table.insert(tags, "Rating: " .. infoData.rating)
	end
	for _, v in ipairs(infoData.tags) do
		table.insert(tags, "Genre: " .. v)
	end
	for _, v in ipairs(infoData.relationships) do
		table.insert(tags, "Relationship: [" .. table.concat(v, ", ") .. "]")
	end
	for _, v in ipairs(infoData.characters) do
		table.insert(tags, "Character: " .. v)
	end

	local status = NovelStatus.PUBLISHING
	if infoData.completed then
		status = NovelStatus.COMPLETED
	end

	extras = extras or {}

	return NovelInfo {
		title = novelTitle,
		link = novelURL,
		imageURL = thumbnail,
		language = infoData.language,
		description = extras.description,
		authors = extras.authors,
		wordCount = infoData.wordCount,
		chapterCount = infoData.chapterCount,
		commentCount = infoData.reviewCount,
		favoriteCount = infoData.favCount,
		status = status,
		genres = tags,
	}
end

local function abbrevToCount(value)
	if value == nil then
		return 0
	end
	value = tostring(value):gsub(",", ""):gsub("%s+", ""):lower()
	local num, suffix = value:match("^([%d%.]+)([km%+]*)$")
	if num == nil then
		return parseCount(value)
	end
	local n = tonumber(num) or 0
	if suffix:find("k", 1, true) then
		n = n * 1000
	elseif suffix:find("m", 1, true) then
		n = n * 1000000
	end
	return math.floor(n)
end

-- Mobile story pages use a compact comma-separated header instead of span.xgray.
local function parseMobileMetaText(text)
	text = (text or ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
	local ratedChunk = text:match("[Rr]ated:%s*(.-)%s*[Pp]ublished:")
			or text:match("[Rr]ated:%s*(.-)%s*[Uu]pdated:")
			or text:match("[Rr]ated:%s*(.+)$")
	if ratedChunk == nil then
		return nil
	end

	local parts = {}
	for raw in (ratedChunk .. ","):gmatch("(.-),") do
		local part = raw:match("^%s*(.-)%s*$")
		if part ~= nil and part ~= "" then
			table.insert(parts, part)
		end
	end

	local rating, language, tags, characters
	local wordCount, favCount, followsCount, reviewCount, chapterCount = 0, 0, 0, 0, 0
	for _, part in ipairs(parts) do
		if startsWith(part, "Words:") then
			wordCount = abbrevToCount(part:gsub("Words:%s*", ""))
		elseif startsWith(part, "Favs:") then
			favCount = abbrevToCount(part:gsub("Favs:%s*", ""))
		elseif startsWith(part, "Follows:") then
			followsCount = abbrevToCount(part:gsub("Follows:%s*", ""))
		elseif startsWith(part, "Reviews:") then
			reviewCount = abbrevToCount(part:gsub("Reviews:%s*", ""))
		elseif startsWith(part, "Chapters:") then
			chapterCount = abbrevToCount(part:gsub("Chapters:%s*", ""))
		elseif rating == nil then
			rating = part:gsub("^Fiction%s+", "")
		elseif language == nil then
			language = part
		else
			local genreCandidate = part:gsub("%s*&%s*", "/")
			local genres = getGenres(genreCandidate)
			if tags == nil and genres ~= nil then
				tags = genres
			elseif characters == nil then
				characters = part
			end
		end
	end

	return {
		rating = rating,
		language = language,
		tags = tags or {},
		characters = characters or "",
		wordCount = wordCount,
		favCount = favCount,
		followsCount = followsCount,
		reviewCount = reviewCount,
		chapterCount = chapterCount,
	}
end

local function novelInfoFromParsed(infoData, novelURL, novelTitle, thumbnail, extras)
	extras = extras or {}
	local tags = {}
	if infoData.rating ~= nil and infoData.rating ~= "" then
		table.insert(tags, "Rating: " .. infoData.rating)
	end
	for _, v in ipairs(infoData.tags or {}) do
		table.insert(tags, "Genre: " .. v)
	end
	for _, v in ipairs(infoData.relationships or {}) do
		table.insert(tags, "Relationship: [" .. table.concat(v, ", ") .. "]")
	end
	if type(infoData.characters) == "table" then
		for _, v in ipairs(infoData.characters) do
			if type(v) == "string" then
				table.insert(tags, "Character: " .. v)
			end
		end
	elseif type(infoData.characters) == "string" and infoData.characters ~= "" then
		for rawChar in (infoData.characters .. ","):gmatch("([^,]+)") do
			local char = rawChar:match("^%s*(.-)%s*$")
			if char ~= nil and char ~= "" then
				table.insert(tags, "Character: " .. char)
			end
		end
	end

	local status = NovelStatus.PUBLISHING
	if infoData.completed then
		status = NovelStatus.COMPLETED
	end

	return NovelInfo {
		title = novelTitle,
		link = novelURL,
		imageURL = thumbnail,
		language = infoData.language,
		description = extras.description,
		authors = extras.authors,
		wordCount = infoData.wordCount,
		chapterCount = infoData.chapterCount,
		commentCount = infoData.reviewCount,
		favoriteCount = infoData.favCount,
		status = status,
		genres = tags,
	}
end

local function buildChapters(document, storyId, novelTitle)
	local chapterSelector = document:selectFirst("#chap_select")
			or document:selectFirst("select#chap_select")
			or document:selectFirst("select[name=chapter]")
	if chapterSelector ~= nil then
		return map(chapterSelector:select("option"), function(v, i)
			local idx = v:attr("value")
			if idx == nil or idx == "" then
				idx = tostring(i + 1)
			end
			return NovelChapter {
				order = tonumber(idx) or (i + 1),
				title = v:text(),
				link = chapterURL(storyId, idx)
			}
		end)
	end

	-- Mobile pages expose chapter count as `var chs = N`
	local html = document:html()
	local chs = tonumber(html:match("var%s+chs%s*=%s*(%d+)"))
	if chs ~= nil and chs > 0 and storyId ~= nil then
		local chapters = {}
		for i = 1, chs do
			table.insert(chapters, NovelChapter {
				order = i,
				title = "Chapter " .. tostring(i),
				link = chapterURL(storyId, i)
			})
		end
		return chapters
	end

	return {
		NovelChapter {
			order = 1,
			title = novelTitle,
			link = chapterURL(storyId, 1)
		}
	}
end

--- @param novelURL string
--- @param loadChapters boolean
--- @return NovelInfo
local function parseNovel(novelURL, loadChapters)
	if novelURL:match("^how") then
		return NovelInfo {
			title = "How to use this source",
			description = "You can use this source by:\n1. Searching by keywords.\n2. Pasting a fanfiction.net story URL into search.\n3. Pasting a browse/category URL (for example /movie/Avengers/) into search and using filters.\n4. Opening the Default listing for recently updated stories."
		}
	end

	local storyId = storyIdFromURL(novelURL)
	local normalized = normalizeNovelURL(novelURL)
	-- Android clients often receive mobile HTML without #profile_top / span.xgray.
	local document = GETDocument(expandURL(normalized))

	local profile = document:selectFirst("#profile_top")
	local novelTitle, thumbnail, authors, description, info

	if profile ~= nil then
		local titleEl = profile:selectFirst("b.xcontrast_txt")
				or profile:selectFirst("b")
		novelTitle = titleEl and titleEl:text() or "Unknown Title"

		thumbnail = extractStoryImage(document, profile)

		local authorEl = profile:selectFirst("a[href*='/u/']")
		if authorEl ~= nil then
			authors = { authorEl:text() }
		end

		local descEl = profile:selectFirst("div.xcontrast_txt")
		description = descEl and descEl:text() or ""

		local meta = profile:selectFirst("span.xgray, .xgray, span.xgray.xcontrast_txt")
				or document:selectFirst("span.xgray, .xgray")
		if meta ~= nil then
			info = parseInfoDataIntoNovelInfo(
					meta,
					normalized,
					novelTitle,
					thumbnail,
					{ description = description, authors = authors }
			)
		end
	end

	-- Mobile / stripped layout fallback (no #profile_top / span.xgray)
	if info == nil then
		local titleEl = document:selectFirst("#content div[align=center] b")
				or document:selectFirst("#content b")
				or document:selectFirst("div[align=center] b")
				or document:selectFirst("b")
		novelTitle = (titleEl and titleEl:text()) or novelTitle or "Unknown Title"

		if authors == nil then
			local authorEl = document:selectFirst("#content a[href*='/u/']")
					or document:selectFirst("a[href*='/u/']")
			if authorEl ~= nil then
				authors = { authorEl:text() }
			end
		end

		thumbnail = thumbnail or extractStoryImage(document, profile)

		local content = document:selectFirst("#content") or document:selectFirst("body")
		local contentText = content and content:text() or document:text()
		local mobileMeta = parseMobileMetaText(contentText)

		-- Chapter count from JS when mobile omits Chapters: in the header
		local html = document:html()
		local chs = tonumber(html:match("var%s+chs%s*=%s*(%d+)"))
		if mobileMeta ~= nil and (mobileMeta.chapterCount == nil or mobileMeta.chapterCount == 0) and chs then
			mobileMeta.chapterCount = chs
		end

		local dates = document:select("span[data-xutime]")
		local updated, published = 0, 0
		if dates ~= nil and dates:size() >= 2 then
			published = (tonumber(dates:get(0):attr("data-xutime")) or 0) * 1000
			updated = (tonumber(dates:get(1):attr("data-xutime")) or 0) * 1000
		elseif dates ~= nil and dates:size() == 1 then
			published = (tonumber(dates:get(0):attr("data-xutime")) or 0) * 1000
			updated = published
		end

		if mobileMeta ~= nil then
			mobileMeta.updated = updated
			mobileMeta.published = published
			mobileMeta.completed = contentText:match("Status:%s*Complete") ~= nil
			mobileMeta.relationships = {}
			info = novelInfoFromParsed(
					mobileMeta,
					normalized,
					novelTitle,
					thumbnail,
					{ description = description or "", authors = authors }
			)
		else
			-- Last resort: still return title/author/chapters rather than hard-failing
			if novelTitle == nil or novelTitle == "Unknown Title" then
				local pageTitle = document:selectFirst("title")
				if pageTitle ~= nil then
					local t = pageTitle:text():gsub("^Fanfic:%s*", ""):gsub("%s*Ch%s*%d+.*$", "")
					if t ~= nil and t ~= "" then
						novelTitle = t
					end
				end
			end
			info = NovelInfo {
				title = novelTitle or "Unknown Title",
				link = normalized,
				imageURL = thumbnail,
				authors = authors,
				description = description or "",
				chapterCount = chs,
			}
		end
	end

	if loadChapters then
		info:setChapters(AsList(buildChapters(document, storyId, novelTitle or "Chapter")))
	end

	return info
end

--- @param document Element
--- @return NovelInfo
local function parseBrowseNovel(document)
	local titleElement = document:selectFirst("a.stitle") or document:selectFirst(".stitle")
	if titleElement == nil then
		-- Some mobile markup only has the story anchor
		local anchors = document:select("a[href]")
		if anchors ~= nil then
			for i = 0, anchors:size() - 1 do
				local a = anchors:get(i)
				local href = a:attr("href") or ""
				if href:match("/s/%d+") and (a:text() or "") ~= "" then
					titleElement = a
					break
				end
			end
		end
	end
	if titleElement == nil then
		return nil
	end
	local title = titleElement:text()
	if title == nil or title == "" then
		return nil
	end
	local href = titleElement:attr("href")
	local url = normalizeNovelURL(href)
	local thumbnail = extractImage(titleElement)
			or extractImage(document:selectFirst("img.cimage, img"))
			or extractImage(document)
	local meta = document:selectFirst("div.xgray, span.xgray, .xgray")
	if meta == nil then
		return NovelInfo {
			title = title,
			link = url,
			imageURL = thumbnail
		}
	end
	return parseInfoDataIntoNovelInfo(meta, url, title, thumbnail)
end

local function parseListingDocument(document)
	local results = {}
	local seen = {}

	local function addFromRow(row)
		local novel = parseBrowseNovel(row)
		if novel == nil then
			return
		end
		local link = novel:getLink()
		if link ~= nil and seen[link] then
			return
		end
		if link ~= nil then
			seen[link] = true
		end
		table.insert(results, novel)
	end

	local rows = document:select("div.z-list, .z-list")
	if rows ~= nil and rows:size() > 0 then
		for i = 0, rows:size() - 1 do
			addFromRow(rows:get(i))
		end
	end

	if #results == 0 then
		-- FanFiction.lua style / tighter mobile layouts
		local titles = document:select("#content_wrapper_inner a.stitle, a.stitle")
		if titles ~= nil then
			for i = 0, titles:size() - 1 do
				local a = titles:get(i)
				local parent = a:parent()
				if parent ~= nil and parent:parent() ~= nil then
					-- Prefer the z-list-like container when present
					local row = a:parent()
					local guard = 0
					while row ~= nil and guard < 5 do
						local cls = row:attr("class") or ""
						if cls:find("z%-list", 1, false) then
							break
						end
						row = row:parent()
						guard = guard + 1
					end
					if row == nil then
						row = parent
					end
					addFromRow(row)
				else
					addFromRow(a)
				end
			end
		end
	end

	return results
end

local function searchFilters()
	local function names(options)
		local out = {}
		for _, option in ipairs(options) do
			table.insert(out, option.name)
		end
		return out
	end

	return {
		DropdownFilter(SORT_ID, "Sort", names(SortOptions)),
		DropdownFilter(TIME_RANGE_ID, "Time Range", names(TimeRangeOptions)),
		DropdownFilter(GENRE_A_ID, "Genre (A)", names(GenreOptions)),
		DropdownFilter(GENRE_B_ID, "Genre (B)", names(GenreOptions)),
		DropdownFilter(RATING_ID, "Rating", names(RatingOptions)),
		DropdownFilter(LANGUAGE_ID, "Language", names(LanguageOptions)),
		DropdownFilter(LENGTH_ID, "Length", names(LengthOptions)),
		DropdownFilter(STATUS_ID, "Status", names(StatusOptions)),
		DropdownFilter(GENRE_EXCLUDE_ID, "Genre (Exclude)", names(GenreOptions)),
	}
end

--- Build ?a=b&c=d query string (no leading ?).
local function buildQuery(params)
	local parts = {}
	for _, pair in ipairs(params) do
		local k, v = pair[1], pair[2]
		if v ~= nil and v ~= "" then
			table.insert(parts, urlEncode(tostring(k)) .. "=" .. urlEncode(tostring(v)))
		end
	end
	return table.concat(parts, "&")
end

--- @param filters table
--- @return table list of {key,value}
local function filterQueryPairs(filters)
	local pairs = {
		{ "srt", dropdownValue(SortOptions, filters[SORT_ID], 1) },
		{ "r", dropdownValue(RatingOptions, filters[RATING_ID], 1) },
	}
	if filters[TIME_RANGE_ID] ~= nil then
		table.insert(pairs, { "t", dropdownValue(TimeRangeOptions, filters[TIME_RANGE_ID], 1) })
	end
	if filters[GENRE_A_ID] ~= nil then
		table.insert(pairs, { "g1", dropdownValue(GenreOptions, filters[GENRE_A_ID], 1) })
	end
	if filters[GENRE_B_ID] ~= nil then
		table.insert(pairs, { "g2", dropdownValue(GenreOptions, filters[GENRE_B_ID], 1) })
	end
	if filters[LANGUAGE_ID] ~= nil then
		table.insert(pairs, { "lan", dropdownValue(LanguageOptions, filters[LANGUAGE_ID], 1) })
	end
	if filters[LENGTH_ID] ~= nil then
		table.insert(pairs, { "len", dropdownValue(LengthOptions, filters[LENGTH_ID], 1) })
	end
	if filters[STATUS_ID] ~= nil then
		table.insert(pairs, { "s", dropdownValue(StatusOptions, filters[STATUS_ID], 1) })
	end
	if filters[GENRE_EXCLUDE_ID] ~= nil then
		table.insert(pairs, { "_g1", dropdownValue(GenreOptions, filters[GENRE_EXCLUDE_ID], 1) })
	end
	return pairs
end

local function withQuery(url, query)
	if query == nil or query == "" then
		return url
	end
	if url:find("?", 1, true) then
		return url .. "&" .. query
	end
	return url .. "?" .. query
end

local function isBrowsePath(path)
	if path == nil or path == "" then
		return false
	end
	if path:match("^/s/%d+") then
		return false
	end
	if path:match("^/search/?") then
		return false
	end
	-- category / fandom / just-in style paths, e.g. /movie/Avengers/ or /j/0/0/0/
	return path:match("^/[^/]+/.+") ~= nil
end

local function getDefaultListing(data, inc)
	local page = 1
	if type(inc) == "number" then
		page = inc
	elseif type(data) == "number" then
		page = data
	elseif type(data) == "table" then
		page = tonumber(data[PAGE]) or 1
	end
	if page < 1 then
		page = 1
	end
	-- Avoid HttpUrl builders; plain GET matches the working reference extension.
	local url = expandURL("/j/0/0/0/?p=" .. tostring(page))
	local document = GETDocument(url)
	return parseListingDocument(document)
end

--- @param filters table @of applied filter values [QUERY] is the search query, may be empty
--- @return NovelInfo[]
local function search(filters)
	local page = tonumber(filters[PAGE]) or 1
	local query = filters[QUERY] or ""
	query = query:gsub("^%s*(.-)%s*$", "%1")

	if query == "" then
		return {}
	end

	-- Direct story URL (www / m / relative)
	local storyId = storyIdFromURL(query)
	if storyId ~= nil then
		if page ~= 1 then
			return {}
		end
		local novelUrl = normalizeNovelURL(query)
		local novel = parseNovel(novelUrl, false)
		return { novel }
	end

	local path = shrinkURL(query)
	-- Full or relative browse/category URL
	if query:find("fanfiction%.net") or isBrowsePath(path) then
		local browseURL
		if query:find("^https?://") or query:find("^//") then
			browseURL = expandURL(shrinkURL(query))
		else
			browseURL = expandURL(path)
		end
		-- Strip existing page query then apply filters + page
		browseURL = browseURL:gsub("[?&]p=%d+", ""):gsub("?$", "")
		local q = buildQuery(filterQueryPairs(filters))
		q = q .. (q ~= "" and "&" or "") .. "p=" .. tostring(page)
		local document = GETDocument(withQuery(browseURL, q))
		return parseListingDocument(document)
	end

	-- Keyword search — do not apply category-browse filter params (they empty results).
	-- Filters are optional extras only where FFN search form understands them.
	local params = {
		{ "keywords", query },
		{ "ready", "1" },
		{ "type", "story" },
		{ "match", "any" },
		{ "ppage", tostring(page) },
	}
	-- Optional language only (common need); 0 means any
	if filters[LANGUAGE_ID] ~= nil then
		local lan = dropdownValue(LanguageOptions, filters[LANGUAGE_ID], 1)
		if lan ~= nil and lan ~= "0" then
			table.insert(params, { "languageid", lan })
		end
	end
	if filters[STATUS_ID] ~= nil then
		local st = dropdownValue(StatusOptions, filters[STATUS_ID], 1)
		if st ~= nil and st ~= "0" then
			table.insert(params, { "statusid", st })
		end
	end
	if filters[GENRE_A_ID] ~= nil then
		local g = dropdownValue(GenreOptions, filters[GENRE_A_ID], 1)
		if g ~= nil and g ~= "0" then
			table.insert(params, { "genreid", g })
		end
	end
	if filters[GENRE_B_ID] ~= nil then
		local g = dropdownValue(GenreOptions, filters[GENRE_B_ID], 1)
		if g ~= nil and g ~= "0" then
			table.insert(params, { "genreid2", g })
		end
	end
	if filters[RATING_ID] ~= nil then
		-- FFN search uses censorid roughly; keep simple — only pass when not All
		local r = dropdownValue(RatingOptions, filters[RATING_ID], 1)
		if r ~= nil and r ~= "10" then
			table.insert(params, { "censorid", r })
		end
	end

	local searchURL = expandURL("/search/?" .. buildQuery(params))
	local document = GETDocument(searchURL)
	return parseListingDocument(document)
end


return {
	id = 1308639979,
	name = "FanFiction.net",
	baseURL = baseURL,

	imageURL = "https://www.fanfiction.net/static/icons3/ff-icon-192.png",
	hasCloudFlare = true,
	hasSearch = true,
	isSearchIncrementing = true,

	chapterType = ChapterType.HTML,

	listings = {
		Listing("Default", true, getDefaultListing),
		Listing("How to use", false, function()
			return {
				Novel {
					title = "How to use this source",
					link = "how"
				}
			}
		end),
	},

	getPassage = getPassage,
	parseNovel = parseNovel,
	search = search,
	searchFilters = searchFilters(),

	updateSetting = function(id, value)
		settings[id] = value
	end,

	shrinkURL = shrinkURL,
	expandURL = expandURL
}
