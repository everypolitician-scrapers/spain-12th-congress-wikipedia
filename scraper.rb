#!/bin/env ruby
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'
require 'wikidata_ids_decorator'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class MembersPage < Scraped::HTML
  decorator WikidataIdsDecorator::Links

  field :members do
    member_table.xpath('.//tr[td]').map { |tr| fragment(tr => MemberRow).to_h }
  end

  private

  def member_table
    noko.xpath('//table[.//th[contains(.,"Circunscripción")]]')
  end
end

class MemberRow < Scraped::HTML
  field :id do
    tds[0].css('a/@wikidata').map(&:text).first
  end

  field :name do
    tds[0].css('a').map(&:text).first
  end

  field :faction do
    tds[2].text.tidy
  end

  field :area do
    tds[5].text.tidy
  end

  field :area_wikidata do
    tds[5].css('a/@wikidata').map(&:text).first
  end

  private

  def tds
    noko.css('td')
  end
end

url = 'https://es.wikipedia.org/wiki/Anexo:Diputados_de_la_XII_legislatura_de_Espa%C3%B1a'
Scraped::Scraper.new(url => MembersPage).store(:members, index: %i[name area faction])
